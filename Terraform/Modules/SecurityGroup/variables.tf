# General infrastructure specifications
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

variable "sg_name" {
	description = "Name of the Security Group created and used for the project."
	type        = string
	default     = "Security_Group"
}

variable "inbound_access_port" {
	description = "Port for allowing external access to applications."
	type        = map(number)
	default     = {
		Jenkins   = 8080
		Nexus     = 8081
		SonarQube = 9000
		SSH       = 22
	}
}