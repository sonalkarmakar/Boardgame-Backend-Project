variable "infra_region" {
	description = "AWS Region where the infrastrucure will be created."
	type        = string
	default     = "ap-south-1"
}

variable "project_prefix" {
	description = "A prefix used for naming infrastructure components."
	type        = string
	default     = "BoardGame_Backend"
}

variable "ssh_key_name" {
	description = "Name of the SSH key-pair to be used to access EC2 instances."
	type        = string
	default     = "EC2_SSH_key"
}