data "aws_ami" "latest_ubuntu_lts" {
	most_recent = true
	owners      = ["099720109477"]

	filter {
		name   = "name"
		values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-*-amd64-server-*"]
	}

	filter {
		name   = "root-device-type"
		values = ["ebs"]
	}
}

resource "aws_instance" "compute_instance" {
	ami                    = "ami-07a00cf47dbbc844c"
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