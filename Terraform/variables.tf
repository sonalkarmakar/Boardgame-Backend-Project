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

variable "ec2_ssh_key_name" {
	description = "Name of the SSH key-pair to be used to access EC2 instances."
	type        = string
	default     = "EC2_SSH_key"
}

variable "ansible_ssh_key_name" {
	description = "Name of the SSH key-pair to be used by Ansible to manage nodes."
	type        = string
	default     = "Ansible_SSH_key"
}

# Application access ports
variable "external_access_ports" { # Should be replaced with user-input
	description = "Ports used for accessing project resources externally."
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
	}
}

variable "default_access_ports" { # DO NOT REPLACE WITH USER-INPUT
	description = "Default ports used by the respective application for access. DO NOT REPLACE WITH USER-INPUT!"
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
	}
}

# Security Group specifications
variable "sg_name" {
	description = "Name of the Security Group created and used for the project."
	type        = string
	default     = "Security_Group"
}

# EC2 specifications
variable "ec2_instances" {
	description = "Specifications for creating the EC2 instances requried for the project."
	type        = map(object({
		name      = string
		type      = string
		root_size = number
	}))
	default = {
		Ansible = { # Ansible control node
			name      = "Ansible"
			type      = "t2.nano"
			root_size = 8
		}
		Jenkins = { # Jenkins host
			name      = "Jenkins"
			type      = "t2.small"
			root_size = 20
		}
		# Kubernetes = { # Kubernetes cluster unit
		# 	name      = "Kube_Cluster"
		# 	type      = "t2.small"
		# 	root_size = 20
		# }
		# Monitoring = { # Hosts Prometheus, Blackbox exporter and Grafana for monitoring
		# 	name      = "Monitoring"
		# 	type      = "t2.small"
		# 	root_size = 16
		# }
		Nexus = { # Nexus repository host
			name      = "Nexus"
			type      = "t2.small"
			root_size = 20
		}
		SonarQube = { # SonarQube host
			name      = "SonarQube"
			type      = "t2.medium"
			root_size = 20
		}
	}
}