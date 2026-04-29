# Deployment Process
The steps for deploying this project are described below.

## Prerequisites
- Create or acquire an [AWS account](https://aws.amazon.com/resources/create-account/) with privileges to create and delete the following resources:
	- EC2 instances
	- Security Group with inbound and outbound rules
	- IAM User
	- AWS Access Key
- [Generate an Access Key](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-key-self-managed.html#Using_CreateAccessKey) for your AWS account that has the privileges mentioned above. Avoid using Root User, create an IAM User if needed.
- [Install Terraform](https://developer.hashicorp.com/terraform/install).
- [Install AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- Configure AWS CLI to connect to you AWS account:
	- Run the command `aws configure`.
	- Enter the ID of the access key generated previously.
	- Enter the secret of the access key.
	- Enter your preferred [AWS Region's code](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints) for this project.
	- Enter your preferred [output format](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output-format.html).