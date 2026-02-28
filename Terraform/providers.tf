terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 6.34.0"
		}
		tls = {
			source  = "hashicorp/tls"
			version = "~> 4.2.1"
		}
		local = {
			source  = "hashicorp/local"
			version = "~> 2.7.0"
		}
		null = {
			source  = "hashicorp/null"
			version = "~> 3.2.4"
		}
	}
}

provider "aws" {
	region = var.infra_region
}