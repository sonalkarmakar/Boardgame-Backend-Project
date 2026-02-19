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
	filename        = "${path.root}/.ssh/${var.project_prefix}-${var.ec2_ssh_key_name}.pem"
	file_permission = "0644"
}

# Security Group module
module "sg_module" {
	source = "./SecurityGroup" #"${path.root}/SecurityGroup"

	infra_region   = var.infra_region
	project_prefix = var.project_prefix
	sg_name        = var.sg_name
}

# EC2 Instance module
module "ec2_module" {
	source = "./EC2" #"${path.root}/EC2"
}