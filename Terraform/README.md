# Terraform Files
This directory contains files required and relevant to Terraform for creating the infrastructure using AWS.

# Modules
These are different modules used in Terraform to define the infrasturucture.

## Main Module
This is the main module that will define other modules, and the general/common components used by those modules.

### Variables
#### General Infrastructure
- Infrastrucutre region (AWS region).
- Project prefix to be used for naming resources.
- SSH key-pair name.

#### Ports
- Jenkins port for external access.
- Nexus repository port for external access.
- SonarQube port for external access.
- SSH port for external access to EC2 instances.

## Security Group Module
This module handles the definitions of Security Group used by this project.

### Constants
- External access must be allowed from everywhere (CIDR 0.0.0.0/0)

### Variables

#### General
- Group name

#### Ports
- Jenkins port for external access.
- Nexus repository port for external access.
- SonarQube port for external access.
- SSH port for external access to EC2 instances.

## EC2 Instance Module
This module handles the definitions of EC2 instances required by the project.

### Constants
- Amazon Machine Image is Ubuntu.
- Root block must be destroyed on instance termination.
- Root block volume type is General Purpose 3 (GP3).

### Variables
- Instance name
- Instance type
- SSH key-pair
- Root block size
- Security Group ID