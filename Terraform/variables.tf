# Project specifications
variable "secrets_dir" {
	description = "Name of the directory containing secrets like SSH keys and AWS access keys."
	type        = string
	default     = ".secrets"
}

variable "access_key_filename" {
	description = "Name of the file that will store the AWS Access Key for EKS cluster admin IAM user."
	type        = string
	default     = "AWS_Access_Key.csv"
}

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

variable "ec2_username" {
	description = "Default username of the primary EC2 instance user."
	type        = string
	default     = "ubuntu"
}

variable "ansible_ssh_key_name" {
	description = "Name of the SSH key-pair to be used by Ansible to manage nodes."
	type        = string
	default     = "Ansible_SSH_key"
}

variable "eks_cluster_admin_username" {
	description = "Username of the IAM User that will be the EKS cluster admin."
	type        = string
	default     = "cluster_admin"
}

variable "eks_cluster_admin_display" {
	description = "Name showin in AWS Console for the EKS cluster admin."
	type        = string
	default     = "ClusterAdmin"
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
		SSH_Alt    = 443
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
		SSH_Alt    = 443
	}
}

# Security Group specifications
variable "sg_name" {
	description = "Name of the Security Group created and used for the project."
	type        = string
	default     = "Security_Group"
}

# IAM User specifications
variable "eks_admin_managed_policies" {
	description = "Policies required by the IAM user for cluster administration."
	type        = list
	default     = [
		"AWSCloudFormationFullAccess",
		"AmazonEC2FullAccess",
	]
}

# EC2 specifications
variable "ec2_instances" {
	description = "Specifications for creating the EC2 instances requried for the project."
	type        = map(object({
		name      = string
		type      = string
		root_size = number
	}))
	default     = {
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