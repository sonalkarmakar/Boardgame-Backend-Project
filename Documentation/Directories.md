# Directories
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
Contains documentation about this project
## Files
- **`Directories.md`**: contains description of different directories and files.
- 

## Ansible
Contains Ansible inventory and playbook, to be run in the control node created in AWS.
### Files
- **`01_InstallDocker.yaml`**: Ansible playbook for installing Docker in the managed nodes.
- **`02_RunDockerContainers.yaml`**: Ansible playbook for running the necessary Docker containers in managed nodes.
- **`03_ConfigureJenkinsContainer.yaml`**: Ansible playbook for configuring the Jenkins container for the project.
- **`04_RetrieveInitialPasswords.yaml`**: Ansible playbook for retrieving initial passwords for Jenkins and Nexus.
- **`05_InstallClusterTools.yaml`**: Ansible playbook for installing AWS CLI v2, Eksctl and `kubectl`.
- **`06_RunMonitoringContainers.yaml`**: Ansible playbook for running Docker containers for Blackbox exporter, Grafana and Prometheus.
- **`inventory.ini`**: Ansible inventory defining the managed nodes and related variables.

## Docker
Contains the Dockerfile to create container image of the board game builds.
### Files
- **`Dockerfile`**: builds Docker image from the builds of the board game source code.

## Jenkins
Contains the Jenkinsfile that's required for building the board game from the source-code.
## Files
- **`Jenkinsfile`**: contains the pipeline script for building the board game from source-code.

## Kubernetes
Contains the YAML files defining the Kubernetes resources for deploying the board game.
## Files
- **`deployment.yaml`**: defines the Kubernetes deployment for the board game.
- **`service.yaml`**: defines the Kubernetes service for the board game.

## SonarQube
Contains configuration file for SonarQube scanner.
### Files
- **`sonar-project.properties`**: Contains the project's configuration data for scanning with SonarQube.

## Terraform
Contains all the files required by Terraform for creating the AWS infrastructure for the project.
### Modules
Contains the different Terraform modules, structured for organisation.
#### EC2
Contains the files for the module dealing with EC2 instances.
##### Files
- **`main.tf`**: main script that defines EC2 module and its tasks.
- **`outputs.tf`**: defines the outputs given by the EC2 module to the main module, or to be used with other modules.
- **`variables.tf`**: defines the variables and default values for Terraform to use for the EC2 module.
#### SecurityGroup
Contains the files for the module dealing with Security Groups.
##### Files
- **`main.tf`**: main script that defines Security Group module and its tasks.
- **`outputs.tf`**: defines the outputs given by the Security Group module to the main module, or to be used with other modules.
- **`variables.tf`**: defines the variables and default values for Terraform to use for the Security Group module.
### Templates
Contains the tempaltes for Terraform to generate other necessary files.
#### Files
- **`ansible_inventory.ini.tftpl`**: template for generating the Ansible inventory inside the "Ansibe" directory.
- **`pom_template.xml`**: template for generating the 
### Files
- **`main.tf`**: main Terraform module that is executed by the user.
- **`providers.tf`**: defines the providers for Terraform to use.
- **`terraform.tfvars`**: provides the input values for the Terraform variables, to be edited by the user.
- **`variables.tf`**: defines the variables and default values for Terraform to use for the infrastructure.

## Files
- **`mvnw`**: shell script that invokes a wrapper for Maven.
- **`mvnw.cmd`**: CMD script that invokes the Maven wrapper.
- **`pom.xml`**: Maven's Project Object Model file that defines and describes the project's parameters.