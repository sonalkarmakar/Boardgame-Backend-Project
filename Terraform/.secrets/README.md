# Secrets
This directory holds sensitive data like access keys, SSH keys and credentials.

> [!WARNING]  
> **Do not share these with _unauthorised_ or _untrusted personnel_.**  
> These credentials are **CRITICAL and SENSITIVE**. They're used for **authenticating access** to powerful resources like _AWS account_, _remote access_ to EC2 instances, etc.  

## SSH Keys
This directory stores the files containing the public and private SSH keys for the following purposes--
- Accessing EC2 instances remotely.
- Ansible remote access for automation.

## AWS Access Keys
This directory stores the AWS Access Keys created by Terraform for the following IAM Users--
- EKS cluster administrator.