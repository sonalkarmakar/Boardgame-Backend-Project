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
		Blackbox   = 9115
		Grafana    = 3000
		Jenkins    = 8080
		Kubernetes = 6443
		Nexus      = 8081
		Prometheus = 9090
		SonarQube  = 9000
		SSH        = 22
		SSH_Alt    = 443
	}
}