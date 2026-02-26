# General infrastructure specifications
infra_region         = "ap-south-1"
project_prefix       = "BoardGame_Backend"
ec2_ssh_key_name     = "EC2_SSH_key"
ansible_ssh_key_name = "Ansible_SSH_key"

# External access ports
external_access_ports = {
	Jenkins    = 8080
	Kubernetes = 6443
	Nexus      = 8081
	SonarQube  = 9000
	SSH        = 22
}

# Security Group specifications
sg_name = "Security_Group"

# EC2 instance specifications
ec2_instances = {
	Ansible = {
		name      = "Ansible"
		type      = "t2.micro"
		root_size = 24
	}
	Jenkins = {
		name      = "Jenkins"
		type      = "t2.micro"
		root_size = 24
	}
	Nexus = {
		name      = "Nexus"
		type      = "t2.medium"
		root_size = 24
	}
	SonarQube = {
		name      = "SonarQube"
		type      = "t2.medium"
		root_size = 24
	}
}