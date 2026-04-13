# SSH KEY-PAIR FOR ANSIBLE
# Generating SSH key-pair
resource "tls_private_key" "ansible_ssh_key" {
	algorithm = "RSA"
	rsa_bits  = 2048
}
# Saving private key to file
resource "local_file" "ansible_private_key" {
	content         = tls_private_key.ansible_ssh_key.private_key_pem
	filename        = "${path.root}/${var.secrets_dir}/${var.project_prefix}-${var.ansible_ssh_key_name}.pem"
	file_permission = "0400"
	depends_on      = [ tls_private_key.ansible_ssh_key ]
}
# Saving public key to file
resource "local_file" "ansible_public_key" {
	content         = tls_private_key.ansible_ssh_key.public_key_openssh
	filename        = "${path.root}/${var.secrets_dir}/${var.project_prefix}-${var.ansible_ssh_key_name}.pub"
	file_permission = "0644"
	depends_on      = [ tls_private_key.ansible_ssh_key ]
}

# SSH KEY-PAIR FOR EC2 INSTANCE
# Generating SSH key-pair
resource "tls_private_key" "ec2_ssh_key" {
	algorithm = "RSA"
	rsa_bits  = 2048
}
# Saving private key to file
resource "local_file" "ec2_private_key" {
	content         = tls_private_key.ec2_ssh_key.private_key_pem
	filename        = "${path.root}/${var.secrets_dir}/${var.project_prefix}-${var.ec2_ssh_key_name}.pem"
	file_permission = "0600"
	depends_on      = [ tls_private_key.ec2_ssh_key ]
}
# Saving public key to file
resource "local_file" "ec2_public_key" {
	content         = tls_private_key.ec2_ssh_key.public_key_openssh
	filename        = "${path.root}/${var.secrets_dir}/${var.project_prefix}-${var.ec2_ssh_key_name}.pub"
	file_permission = "0644"
	depends_on      = [ tls_private_key.ec2_ssh_key ]
}
# Add key-pair to AWS
resource "aws_key_pair" "ec2_ssh_key" {
	key_name   = "${var.project_prefix}-${var.ec2_ssh_key_name}"
	public_key = tls_private_key.ec2_ssh_key.public_key_openssh
	depends_on = [ tls_private_key.ec2_ssh_key ]
}

# SECURITY GROUP MODULE
module "sg_module" {
	source = "./Modules/SecurityGroup"

	infra_region        = var.infra_region
	project_prefix      = var.project_prefix
	sg_name             = var.sg_name
	inbound_access_port = var.external_access_ports
}

# IAM USER MODULE
module "iam_user" {
	source = "./Modules/IAM"

	username            = "${lower(var.project_prefix)}-${var.eks_cluster_admin_username}"
	user_path           = "/"
	display_name        = "${var.project_prefix}-${var.eks_cluster_admin_display}"
	project_prefix      = var.project_prefix
	managed_policies    = var.eks_admin_managed_policies
	inline_policies     = {
		for policy_file in fileset("${path.root}/Templates", "*.json.tftpl") :
			split(".json.tftpl", policy_file)[0] => "${path.root}/Templates/${policy_file}"
	}
}

# EC2 INSTANCE MODULE
module "ec2_module" {
	source     = "./Modules/EC2"
	depends_on = [ aws_key_pair.ec2_ssh_key, module.sg_module, tls_private_key.ansible_ssh_key ]

	for_each = var.ec2_instances

	instance_name  = "${var.project_prefix}-${each.value.name}"
	instance_type  = each.value.type
	instance_sg    = [ module.sg_module.security_group_id ]
	root_vol_size  = each.value.root_size
	ssh_public_key = aws_key_pair.ec2_ssh_key.key_name

	user_data = <<-EOF
	            #!/usr/bin/env bash
	            echo -e "Port 22\nPort ${var.external_access_ports["SSH_Alt"]}" | sudo tee -a /etc/ssh/sshd_config
	            echo "${tls_private_key.ansible_ssh_key.public_key_openssh}" | sudo tee -a /home/${var.ec2_username}/.ssh/authorized_keys
	            EOF
}

# Reboot EC2 instances once after creation
resource "null_resource" "reboot_ec2_instances" {
	for_each = module.ec2_module

	triggers = {
		instance_id = each.value.instance_id
	}

	provisioner "local-exec" {
		command = "aws ec2 reboot-instances --instance-ids ${each.value.instance_id} --region ${var.infra_region}"
	}

	depends_on = [ module.ec2_module ]
}

# GENERATE FILES FROM TEMPLATES
# Store IAM User Access Key
resource "local_file" "aws_access_key" {
	content = templatefile("${path.root}/Templates/${var.access_key_filename}.tftpl", {
		access_key_id = module.iam_user.eks_admin_key_id,
		access_key_secret = module.iam_user.eks_admin_key_secret
	})

	filename        = "${path.root}/${var.secrets_dir}/${var.access_key_filename}"
	file_permission = "0400"
	depends_on      = [ module.iam_user ]
}

# Get public IP address and access port of nodes, excluding Ansible control node
locals {
	depends_on = [ module.sg_module, module.ec2_module ]

	compute_instances = {
		for key, instance in module.ec2_module :
			key => {
				public_ip = instance.public_ip
				host_port = (
					key == "Monitoring" ?
						[
							module.sg_module.external_access_ports["Blackbox"],
							module.sg_module.external_access_ports["Grafana"],
							module.sg_module.external_access_ports["Prometheus"],
						] :
						[ module.sg_module.external_access_ports[key] ]
				)
			}
			if key != "Ansible"
	}
}

# Write the Ansible inventory file as per template
resource "local_file" "ansible_inventory" {
	content  = templatefile("${path.root}/Templates/ansible_inventory.ini.tftpl", {
		managed_nodes    = local.compute_instances
		ansible_key_name = "${var.project_prefix}-${var.ansible_ssh_key_name}.pem"
		admin_user       = "${var.ec2_username}"
	})
	filename = "${path.root}/../Ansible/inventory.ini"

	depends_on = [ module.ec2_module ]
}

# Add the Nexus instance public IP address as per template
resource "local_file" "maven_pom_xml" {
	content  = replace(
		file("${path.root}/Templates/pom_template.xml"),
		"<!--NEXUS_IP_ADDRESS-->",
		local.compute_instances["Nexus"].public_ip
	)
	filename = "${path.root}/../pom.xml"

	depends_on = [ module.ec2_module ]
}