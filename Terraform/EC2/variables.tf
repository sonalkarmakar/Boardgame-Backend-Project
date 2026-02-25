variable "instance_name" {
	description = "Name of the EC2 instance shown in AWS Console."
	type        = string
	default     = "Project_Compute_Instance"
}

variable "instance_type" {
	description = "Type AWS EC2 instance."
	type        = string
	default     = "t2.medium"
}

variable "root_vol_size" {
	description = "Size of the root volume of the EC2 instance."
	type        = number
	default     = 24
}

variable "ssh_key_name" {
	description = "Name of the SSH key used to access the EC2 instance."
	type        = string
	default     = "EC2_SSH_Key"
}

variable "ssh_public_key" {
	description = "Public SSH key for accessing EC2 instance."
	type        = string
}

variable "instance_sg" {
	description = "List of Security Groups associated with the EC2 instance."
	type        = list(string)
	default     = [  ]
}