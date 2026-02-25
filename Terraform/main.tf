# Generating SSH key-pair
resource "tls_private_key" "ec2_ssh_key" {
	algorithm = "RSA"
	rsa_bits  = 2048
}
# Saving private key to file
resource "local_file" "private_key" {
	content         = tls_private_key.ec2_ssh_key.private_key_pem
	filename        = "${path.root}/.ssh/${var.project_prefix}-${var.ec2_ssh_key_name}.pem"
	file_permission = "0600"
}
# Saving public key to file
resource "local_file" "public_key" {
	content         = tls_private_key.ec2_ssh_key.public_key_openssh
	filename        = "${path.root}/.ssh/${var.project_prefix}-${var.ec2_ssh_key_name}.pub"
	file_permission = "0644"
}

# Security Group module
module "sg_module" {
	source = "./SecurityGroup" #"${path.root}/SecurityGroup"
	for_each = var.external_access_ports

	infra_region        = var.infra_region
	project_prefix      = var.project_prefix
	sg_name             = var.sg_name
	inbound_access_port = each.value
}

# Add key-pair to AWS
resource "aws_key_pair" "ec2_ssh_key" {
	key_name   = "${var.project_prefix}-${var.ec2_ssh_key_name}"
	public_key = tls_private_key.ec2_ssh_key.public_key_openssh
}

# EC2 Instance module
module "ec2_module" {
	source = "./EC2" #"${path.root}/EC2"

	for_each = var.ec2_instances

	instance_name  = "${var.project_prefix}-${each.value.name}"
	instance_type  = each.value.type
	root_vol_size  = each.value.root_size
	ssh_key_name   = "${var.project_prefix}-${var.ec2_ssh_key_name}"
	ssh_public_key = aws_key_pair.ec2_ssh_key.key_name
}