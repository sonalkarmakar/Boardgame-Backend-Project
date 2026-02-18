# Generating SSH key-pair
resource "tls_private_key" "generated_ssh_key" {
	algorithm = "RSA"
	rsa_bits  = 2048
}
# Saving private key to file
resource "local_file" "private_key" {
	content         = tls_private_key.generated_ssh_key.private_key_pem
	filename        = "${path.root}/.ssh/${var.project_prefix}-${var.ssh_key_name}.pem"
	file_permission = "0600"
}
# Saving public key to file
resource "local_file" "public_key" {
	content         = tls_private_key.generated_ssh_key.public_key_openssh
	filename        = "${path.root}/.ssh/${var.project_prefix}-${var.ssh_key_name}.pem"
	file_permission = "0644"
}

# Security Group module
module "sg_module" {
	source = "${path.root}/SecurityGroup"
}

# EC2 Instance module
module "ec2_module" {
	source = "${path.root}/EC2"
}