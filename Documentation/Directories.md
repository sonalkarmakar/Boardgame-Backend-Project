# Directories
## Contents
- [Summary](#summary)
- [Documentation (Current Directory)](#documentation-current-directory)
	- [Attachments](#attachments)
	- [Files in Documentation](#files-in-documentation)
- [Ansible](#ansible)
- [Files in Ansible](#files-in-ansible)
- [Docker](#docker)
- [Files in Docker](#files-in-docker)
- [Jenkins](#jenkins)
- [Files in Jenkins](#files-in-jenkins)
- [Kubernetes](#kubernetes)
- [Files in Kubernetes](#files-in-kubernetes)
- [SonarQube](#sonarqube)
- [Files in SonarQube](#files-in-sonarqube)
- [Terraform](#terraform)
- [Modules](#modules)
	- [EC2](#ec2)
	- [Files in EC2](#files-in-ec2)
	- [SecurityGroup](#securitygroup)
	- [Files in SecurityGroup](#files-in-securitygroup)
- [Templates](#templates)
	- [Files in Templates](#files-in-templates)
- [Files in Terraform](#files-in-terraform)
- [Files in top directory](#files-in-top-directory)

## Summary
This document contains the purpose and short description of the directories and some files in this project.

The current directory strucutre is as follows--
```
.
├── Ansible
│   ├── 01_InstallDocker.yaml
│   ├── 02_RunDockerContainers.yaml
│   ├── 03_ConfigureJenkinsContainer.yaml
│   ├── 04_RetrieveInitialPasswords.yaml
│   ├── 05_InstallClusterTools.yaml
│   ├── 06_RunMonitoringContainers.yaml
│   └── inventory.ini
├── Docker
│   └── Dockerfile
├── Documentation
│   └── Directories.md
├── Jenkins
│   └── Jenkinsfile
├── Kubernetes
│   ├── deployment.yaml
│   └── service.yaml
├── mvnw
├── mvnw.cmd
├── pom.xml
├── README.md
├── SonarQube
│   └── sonar-project.properties
├── src
└── Terraform
	├── main.tf
	├── Modules
	│   ├── EC2
	│   │   ├── main.tf
	│   │   ├── outputs.tf
	│   │   └── variables.tf
	│   ├── IAM
	│   │   ├── main.tf
	│   │   ├── outputs.tf
	│   │   └── variables.tf
	│   └── SecurityGroup
	│       ├── main.tf
	│       ├── outputs.tf
	│       └── variables.tf
	├── providers.tf
	├── Templates
	│   ├── ansible_inventory.ini.tftpl
	│   └── pom_template.xml
	├── terraform.tfvars
	└── variables.tf
```

## Documentation (Current Directory)
Contains documentation about this project.

### Attachments
Contains screenshot/diagram files attached in the documentation.

### Files in Documentation
- **`Directories.md`**: contains description of different directories and files.
- **`ProjectStructure.md`**: contains description of the project's structure.
- **`DeploymentProcess.md`**: detailed steps of deploying the project.
- **`DecommissioningProcess.md`**: steps for decommissioning the deployed infrastructure and resources.

## Ansible
Contains Ansible inventory and playbook, to be run in the control node created in AWS.

### Files in Ansible
- **`01_InstallDocker.yaml`**: Ansible playbook for installing Docker in the managed nodes.
- **`02_RunDockerContainers.yaml`**: Ansible playbook for running the necessary Docker containers in managed nodes.
- **`03_ConfigureJenkinsContainer.yaml`**: Ansible playbook for configuring the Jenkins container for the project.
- **`04_RetrieveInitialPasswords.yaml`**: Ansible playbook for retrieving initial passwords for Jenkins and Nexus.
- **`05_InstallClusterTools.yaml`**: Ansible playbook for installing AWS CLI v2, Eksctl and `kubectl`.
- **`06_RunMonitoringContainers.yaml`**: Ansible playbook for running Docker containers for Blackbox exporter, Grafana and Prometheus.
- **`inventory.ini`**: Ansible inventory defining the managed nodes and related variables.

## Docker
Contains the Dockerfile to create container image of the board game builds.

### Files in Docker
- **`Dockerfile`**: builds Docker image from the builds of the board game source code.

## Jenkins
Contains the Jenkinsfile that's required for building the board game from the source-code.

## Files in Jenkins
- **`Jenkinsfile`**: contains the pipeline script for building the board game from source-code.

## Kubernetes
Contains the YAML files defining the Kubernetes resources for deploying the board game.

## Files in Kubernetes
- **`deployment.yaml`**: defines the Kubernetes deployment for the board game.
- **`service.yaml`**: defines the Kubernetes service for the board game.

## SonarQube
Contains configuration file for SonarQube scanner.

### Files in SonarQube
- **`sonar-project.properties`**: Contains the project's configuration data for scanning with SonarQube.

## Terraform
Contains all the files required by Terraform for creating the AWS infrastructure for the project.

### Modules
Contains the different Terraform modules, structured for organisation.

#### EC2
Contains the files for the module dealing with EC2 instances.

##### Files in EC2
- **`main.tf`**: main script that defines EC2 module and its tasks.
- **`outputs.tf`**: defines the outputs given by the EC2 module to the main module, or to be used with other modules.
- **`variables.tf`**: defines the variables and default values for Terraform to use for the EC2 module.

#### SecurityGroup
Contains the files for the module dealing with Security Groups.

##### Files in SecurityGroup
- **`main.tf`**: main script that defines Security Group module and its tasks.
- **`outputs.tf`**: defines the outputs given by the Security Group module to the main module, or to be used with other modules.
- **`variables.tf`**: defines the variables and default values for Terraform to use for the Security Group module.

### Templates
Contains the tempaltes for Terraform to generate other necessary files.

#### Files in Templates
- **`ansible_inventory.ini.tftpl`**: template for generating the Ansible inventory inside the "Ansibe" directory.
- **`pom_template.xml`**: template for generating the 

### Files in Terraform
- **`main.tf`**: main Terraform module that is executed by the user.
- **`providers.tf`**: defines the providers for Terraform to use.
- **`terraform.tfvars`**: provides the input values for the Terraform variables, to be edited by the user.
- **`variables.tf`**: defines the variables and default values for Terraform to use for the infrastructure.

## Files in top directory
- **`mvnw`**: shell script that invokes a wrapper for Maven.
- **`mvnw.cmd`**: CMD script that invokes the Maven wrapper.
- **`pom.xml`**: Maven's Project Object Model file that defines and describes the project's parameters.