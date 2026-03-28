# Project specifications
secrets_dir = ".ssh"

# General infrastructure specifications
infra_region         = "ap-south-1"
project_prefix       = "BoardGame_Backend"
ec2_ssh_key_name     = "EC2_SSH_key"
ec2_username         = "ubuntu"
ansible_ssh_key_name = "Ansible_SSH_key"

# External access ports
external_access_ports = {
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

# Security Group specifications
sg_name = "Security_Group"

# EC2 instance specifications
ec2_instances = {
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
	# Monitoring = { # Will run Prometheus, Blackbox exporter and Grafana
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