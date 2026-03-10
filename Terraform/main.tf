# SSH Key-Pair for Ansible
# Generating SSH key-pair
resource "tls_private_key" "ansible_ssh_key" {
	algorithm = "RSA"
	rsa_bits  = 2048
}
# Saving private key to file
resource "local_file" "ansible_private_key" {
	content         = tls_private_key.ansible_ssh_key.private_key_pem
	filename        = "${path.root}/.ssh/${var.project_prefix}-${var.ansible_ssh_key_name}.pem"
	file_permission = "0400"
}
# Saving public key to file
resource "local_file" "ansible_public_key" {
	content         = tls_private_key.ansible_ssh_key.public_key_openssh
	filename        = "${path.root}/.ssh/${var.project_prefix}-${var.ansible_ssh_key_name}.pub"
	file_permission = "0644"
}

# SSH Key-Pair for EC2 Instance
# Generating SSH key-pair
resource "tls_private_key" "ec2_ssh_key" {
	algorithm = "RSA"
	rsa_bits  = 2048
}
# Saving private key to file
resource "local_file" "ec2_private_key" {
	content         = tls_private_key.ec2_ssh_key.private_key_pem
	filename        = "${path.root}/.ssh/${var.project_prefix}-${var.ec2_ssh_key_name}.pem"
	file_permission = "0600"
}
# Saving public key to file
resource "local_file" "ec2_public_key" {
	content         = tls_private_key.ec2_ssh_key.public_key_openssh
	filename        = "${path.root}/.ssh/${var.project_prefix}-${var.ec2_ssh_key_name}.pub"
	file_permission = "0644"
}
# Add key-pair to AWS
resource "aws_key_pair" "ec2_ssh_key" {
	key_name   = "${var.project_prefix}-${var.ec2_ssh_key_name}"
	public_key = tls_private_key.ec2_ssh_key.public_key_openssh
}

# Security Group module
module "sg_module" {
	source = "./SecurityGroup"

	infra_region        = var.infra_region
	project_prefix      = var.project_prefix
	sg_name             = var.sg_name
	inbound_access_port = var.external_access_ports
}

# EC2 Instance module
module "ec2_module" {
	source = "./EC2"

	for_each = var.ec2_instances

	instance_name  = "${var.project_prefix}-${each.value.name}"
	instance_type  = each.value.type
	instance_sg    = [ module.sg_module.security_group_id ]
	root_vol_size  = each.value.root_size
	ssh_public_key = aws_key_pair.ec2_ssh_key.key_name
}

# Get public IP address and key name excluding Ansible control node
locals {
	compute_instances = {
		for key, instance in module.ec2_module : key => {
			public_ip = instance.public_ip
		}
		if key != "Ansible"
	}
}
# Write the Ansible inventory file as per template
resource "local_file" "ansible_inventory" {
	content = templatefile("${path.root}/Template/ansible_inventory.ini.tftpl", {
		managed_nodes    = local.compute_instances
		ansible_key_name = "${var.ansible_ssh_key_name}.pem"
	})
	filename = "${path.root}/../Ansible/inventory.ini"

	depends_on = [ module.ec2_module ]
}
# Add the Nexus instance public IP address as per template
resource "local_file" "maven_pom_xml" {
	content    = replace(
		file("${path.root}/../pom_template.xml"),
		"{NEXUS_IP_ADDRESS}",
		local.compute_instances["Nexus"].public_ip
	)
	filename   = "${path.root}/../pom.xml"
	depends_on = [ module.ec2_module ]
}