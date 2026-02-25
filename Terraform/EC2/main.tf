# AMI ID: ami-019715e0d74f695be
resource "aws_instance" "compute_instance" {
	ami = "ami-019715e0d74f695be"
	instance_type = var.instance_type
	
	root_block_device {
		delete_on_termination = true
		volume_type           = "gp3"
		volume_size           = var.root_vol_size
	}
}

resource "aws_key_pair" "instance_key" {
	key_name = var.ssh_key_name
	public_key = var.ssh_public_key
}