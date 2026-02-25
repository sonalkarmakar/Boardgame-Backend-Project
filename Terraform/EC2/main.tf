# AMI ID: ami-019715e0d74f695be
resource "aws_instance" "compute_instance" {
	ami           = "ami-019715e0d74f695be"
	instance_type = var.instance_type
	key_name      = var.ssh_public_key
	
	root_block_device {
		delete_on_termination = true
		volume_type           = "gp3"
		volume_size           = var.root_vol_size
	}
}