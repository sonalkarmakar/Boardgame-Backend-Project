# Deployment Process
The steps for deploying this project are described below.

## Prerequisites
- Create/acquire a [**Docker Hub**](http://hub.docker.com/) account.
- Create/acquire an [**AWS account**](https://aws.amazon.com/resources/create-account/) with privileges to create and delete the following resources:
	- EC2 instances
	- Security Group with inbound and outbound rules
	- IAM User
	- AWS Access Key
- [Generate an **Access Key**](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-key-self-managed.html#Using_CreateAccessKey) for your AWS account that has the privileges mentioned above. Avoid using Root User, create an IAM User if needed.
- [Install **Terraform**](https://developer.hashicorp.com/terraform/install).
- [Install **Git**](https://git-scm.com/install/) and clone this repository to your preferred working directory.
	```sh
	# Choose one below
	git clone https://github.com/sonalkarmakar/Boardgame-Backend-Project.git # using HTTPS
	git clone git@github.com:sonalkarmakar/Boardgame-Backend-Project.git # using SSH
	```
- [Install **AWS CLI v2**](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- Configure AWS CLI to connect to you AWS account:
	- Run the command `aws configure`.
	- Enter the _access key ID_ that was generated previously.
	- Enter the _access key Secret_.
	- Enter your preferred [_AWS Region's code_](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints) for this project.
	- Enter your preferred [_output format_](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output-format.html).

## Step 1: Configure and run Terraform code
- Open the file **`Terraform/terraform.tfvars`** and modify the values of the defined variables as per your reuqirement. Leave default values for variables that aren't required.

> [!IMPORTANT]  
> **Your ISP might be _blocking port 22_ traffic on your networks.**  
> As such, it's recommended to keep `SSH_Alt = 443` in the `external_access_ports` variable, as it's the HTTPS port that's never blocked.  

- Open the **`Terraform`** directory in your **terminal** and run the following commands and wait for execution completion:
	- Initialise Terraform:
		```sh
		terraform init
		```
	- Validate code syntax:
		```sh
		terraform validate
		```
	- Show change plans:
		```sh
		terraform plan
		```
	- Apply planned changes:
		```sh
		terraform apply -auto-approve
		```
		> ✒️ **Note:** Remove the `-auto-approve` flag if you wish to manually approve each change.  

## Step 2: Connect to Control Node and prepare it
- Open the [**AWS Console EC2 Instances page**](https://console.aws.amazon.com/ec2/home?#Instances:) and sign in to your AWS account.
- Ensure that you're in the correct AWS Region from the top-right corner of the web-page.
- Copy the public IP address of the **Control Node** instance. It should be in _Running_ state and have the name in the format "`<Project_Prefix>-<InstanceName>`".
- Copy the following items to the specified directories of the **Control Node** using **Secure Copy (`scp`)**:
	> ℹ️ **Info:** The generated SSH keys are named in the format "`<Project_Prefix>-<Ansible_SSH_Key_Name>`". If you haven't changed the default values in `terraform.tfvars`, the commands below require no modification to key names.  
	- `Ansible/` directory with its contents to _home directory_.
		```sh
		scp -i Terraform/.secrets/BoardGame_Backend-EC2_SSH_key.pem -P 443 -r Ansible/ ubuntu@<ControlNode-Public-IP>:~/
		```
	- `Kubernetes/` directory with its contents to the _home directory_.
		```sh
		scp -i Terraform/.secrets/BoardGame_Backend-EC2_SSH_key.pem -P 443 -r Kubernetes/ ubuntu@<ControlNode-Public-IP>:~/
		```
	- `Terraform/.secrets/BoardGame_Backend-Ansible_SSH_key.pem` to `~/.ssh/` directory.
		```sh
		scp -i Terraform/.secrets/BoardGame_Backend-EC2_SSH_key.pem -P 443 Terraform/.secret/BoardGame_Backend-Ansible_SSH_key.pem ubuntu@<ControlNode-Public-IP>:~/.ssh/
		```
- Connect to the Control Node EC2 instance using SSH.
	```sh
	ssh -i Terraform/.secrets/BoardGame_Backend-Ansible_SSH_key.pem -p 443 ubuntu@<ControlNode-Public-IP>
	```
- Prepare the instance for running Ansible playbooks.
	- Update repositories.
		```sh
		sudo apt update -y
		```
	- Upgrade the system.
		```sh
		sudo apt upgrade -y
		```
	- Install Ansible.
		```sh
		sudo apt install -y ansible
		```
## Step 3: Configure and run Ansible in Control Node
- Ensure that the `Ansible/` directory contains the 6 playbooks and the inventory INI file. If they're not present, use `scp` to copy them from your system.
	```
	ADD SCREENSHOT HERE
	```
- Add remote hosts to list of known hosts. This may not be required, but the next step might fail without it.
	```sh
	ssh-keyscan -H {<remote-host-ip-address_separated-by-comma>} >> ~/.ssh/known_hosts
	```
	Here, "remote hosts" are the other EC2 instances created. Their public IP addresses should be in the file "`Ansible/inventory.ini`".  
	Type "`yes`" when it's waiting for your input.
- Test Ansible connection to the Managed Nodes.
	```sh
	ansible all -i ~/Ansible/inventory.ini -m ping
	```
	If the step above was skipped, you will need to enter "`yes`" when it's waiting for your input.
	```
	ADD SCREENSHOT HERE
	```
- Run the playbooks
	```sh
	ansible-playbook -i ~/Ansible/inventory.ini ~/Ansible/<playbook-file-name>
	```
	- Run `01_InstallDocker.yaml` to **install Docker** in the EC2 instances.
	- Run `02_RunDockerContainers.yaml` to **run the required Docker containers** in their respective EC2 instances.
	- Run `03_ConfigureJenkinsContainer.yaml` to **install necessary tools and plugins** inside the Jenkins container running the _Jenkins EC2 instance_.
	- Run `04_InstallClusterTools.yaml` to install **AWS CLI v2**, **`eksctl`** and **`kubectl`** in the _Control Node_.
	- Run `05_RetrieveInitialPasswords.yaml` to get the **intial admin passwords** for **Jenkins and Nexus** portals. Secure them safely for initial configuration.
	- Run `06_RunMonitoringContainers.yaml` to run **Blackbox Exporter**, **Grafana** and **Prometheus** containers in the _Monitoring EC2 instance_.

> [!NOTE]  
> - All the playbooks are **named/numbered in the sequence** they should be run in.  
> - The playbook "`06_RunMonitoringContainers.yaml`" can also be ran _after_ the application has been deployed. It's your choice.  

## Step 4: Prepare Nexus Repository
- Open the **Nexus Repository web interface** by going to `http://<Nexus-EC2-instance-public-IP-address>:8081`.
- Enter the **initial Nexus Repository admin password** retrieved by `05_RetrieveInitialPasswords.yaml` Ansible playbook, in the _Login_ page.
- Create the **new admin password** when prompted, then continue to the next setup pages.
- Select _Disable anonymous access_ option in the **Configure Anonymous Access** page.

## Step 5: Prepare SonarQube and generate token
### Step 5.1: Initial configuration
- Open the **SonarQube web interface** by going to `http://<SonarQube-EC2-instance-public-IP-address>:9000`.
- Enter "**`admin`**" in **both _Username_ and _Password_** fields to login with the initial admin credentials.
- Create the **new admin password** in the **Update your password** page. Ensure to follow the password rules shown on screen.
- The SonarQube home page should now be visible.

### Step 5.2: Generate token
- [**Generate a token**](https://docs.sonarsource.com/sonarqube-server/user-guide/managing-tokens#generating-a-token) of type _Global Analysis Token_, with your preference for name and expiration.
- **Copy and save the token _IMMEDIATELY_**. This token will _**NOT be available later**_.


## Step 6: Prepare Jenkins for building
### Step 6.1: Initial configuration
- Open the **Jenkins web interface** by going to `http://<Jenkins-EC2-instance-public-IP-address>:8080`.
- Enter the **initial Jenkins admin password** retrieved by `05_RetrieveInitialPasswords.yaml` Ansible playbook, in the **Unlock Jenkins** page.
- Choose your preferred _plugins setup option_ in the **Customize Jenkins** page.
- Enter **new admin credentials** in the **Create First Admin User** page.
- Verify the URL in the Instance Configuration page and click on Save and Finish button.
- The next page should display messages saying that _Jenkins is ready to use_. Click the **Start using Jenkins** button to open the Jenkins home page.

### Step 6.2: Add credentials
- Add Global credentials in Jenkins for the following as the specified types:
	| Credentials                | Jenkins Credential Type                                                                     | Description                                                                                                     |
	|----------------------------|---------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
	| **AWS Access Key**         | AWS Credentials (via [AWS Credentials plugin](https://plugins.jenkins.io/aws-credentials/)) | Access Key generated using Terraform for EKS admin IAM User, stored in `Terraform/.secrets/AWS_Access_Key.csv`. |
	| **Docker Hub credentials** | Username with password                                                                      | Username and password of your Docker Hub account.                                                               |
	| **SonarQube Token**        | Secret text                                                                                 | SonarQube token generated in [previous step](#step-52-generate-token).                                          |

### Step 6.3: Create Maven configuration file
- Ensure that the plugin [Config File Provider](https://plugins.jenkins.io/config-file-provider/) is installed in Jenkins.
- Go to _**Manage Jenkins** > **Managed files**_ (under _**System Configuration** section_).
