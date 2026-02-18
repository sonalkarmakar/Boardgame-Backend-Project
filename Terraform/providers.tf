terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 6.32.1"
		}
		tls = {
			source = "hashicorp/tls"
			version = "~> 4.2.1"
		}
	}
}

provider "aws" {
	region = var.infra_region
}