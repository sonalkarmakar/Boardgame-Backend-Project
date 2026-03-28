resource "aws_instance" "compute_instance" {
	ami                    = "ami-019715e0d74f695be"
	instance_type          = var.instance_type
	key_name               = var.ssh_public_key
	vpc_security_group_ids = var.instance_sg
	user_data              = var.user_data

	tags = {
		Name = var.instance_name
	}
	
	root_block_device {
		delete_on_termination = true
		volume_type           = "gp3"
		volume_size           = var.root_vol_size
	}
}