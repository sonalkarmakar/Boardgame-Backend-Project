# Deployment Process
The steps for deploying this project are described below.

## Prerequisites
- [Optional] Create/acquire an **email address** with the feature of _password-authentication over SMTP_, to be used by Jenkins to send email notifications.
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
- Ensure that you're in the **correct AWS Region** from the _top-right corner_ of the web-page.
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
- Go to _**Manage Jenkins** > **Plugins**_ (under _**System Configuration** section_) and ensure that the following plugins are active:
	- [AWS Credentials](https://plugins.jenkins.io/aws-credentials) (`aws-credentials`)
	- [Config File Provider](https://plugins.jenkins.io/config-file-provider) (`config-file-provider`)
	- [Docker](https://plugins.jenkins.io/docker-plugin) (`docker-plugin`)
	- [Docker Pipeline](https://plugins.jenkins.io/docker-workflow) (`docker-workflow`)
	- [Eclipse Temurin Installer](https://plugins.jenkins.io/adoptopenjdk) (`adoptopenjdk`)
	- [Email Extension](https://plugins.jenkins.io/email-ext) (`email-ext`)
	- [HTML Publisher](https://plugins.jenkins.io/htmlpublisher) (`htmlpublisher`)
	- [Kubernetes](https://plugins.jenkins.io/kubernetes) (`kubernetes`)
	- [Kubernetes CLI](https://plugins.jenkins.io/kubernetes-cli) (`kubernetes-cli`)
	- [Maven Integration](https://plugins.jenkins.io/maven-plugin) (`maven-plugin`)
	- [Nexus Artifact Uploader](https://plugins.jenkins.io/nexus-artifact-uploader) (`nexus-artifact-uploader`)
	- [Pipeline Maven Integration](https://plugins.jenkins.io/pipeline-maven) (`pipeline-maven`)
	- [Pipeline: AWS Steps](https://plugins.jenkins.io/pipeline-aws) (`pipeline-aws`)
	- [SonarQube Scanner](https://plugins.jenkins.io/sonar) (`sonar`)

> [!NOTE]  
> All required Jenkins plugins should be installed automatically by the Ansible playbook "`03_ConfigureJenkinsContainer.yaml`".  
> However, there might be issues where plugins get installed but not enabled.  

### Step 6.2: Add credentials
- Add Global credentials in Jenkins for the following as the specified types:
	| Credentials                | Jenkins Credential Type                                                                     | Description                                                                                                     |
	|----------------------------|---------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------|
	| **AWS Access Key**         | AWS Credentials (via [AWS Credentials plugin](https://plugins.jenkins.io/aws-credentials/)) | Access Key generated using Terraform for EKS admin IAM User, stored in `Terraform/.secrets/AWS_Access_Key.csv`. |
	| **Docker Hub credentials** | Username with password                                                                      | Username and password of your Docker Hub account.                                                               |
	| **SonarQube Token**        | Secret text                                                                                 | SonarQube token generated in [previous section](#step-52-generate-token).                                          |
- Note down the **credential IDs** you used for Jenkins to uniquely identify each credential.

### Step 6.3: Create Maven configuration file
- Go to _**Manage Jenkins** > **Managed files**_ (under _**System Configuration** section_). This option appears if [Config File Provider](https://plugins.jenkins.io/config-file-provider/) plugin is _installed and active_.
- [**Add a new config file**](https://plugins.jenkins.io/config-file-provider/#plugin-content-load-your-configuration-file-content) of type _Global Maven settings.xml_, with a **config file ID** of your preference. Note down the config file ID.
- Modify the XML file using the _Content_ field and add the code below **within the `<servers></servers>` ("servers", plural) tag**.
	```xml
	      <server>
	        <id>maven-releases</id> <!-- Repository ID -->
	        <username><!-- NEXUS_REPO_ADMIN_USERNAME --></username>
	        <password><!-- NEXUS_REPO_ADMIN_PASSWORD --></password>
	      <server>
	      <server>
	        <id>maven-snapshots</id> <!-- Repository ID -->
	        <username><!-- NEXUS_REPO_ADMIN_USERNAME --></username>
	        <password><!-- NEXUS_REPO_ADMIN_PASSWORD --></password>
	      <server>
	```
	Replace **`<!-- NEXUS_REPO_ADMIN_USERNAME -->`** and **`<!-- NEXUS_REPO_ADMIN_PASSWORD -->`** with the _Nexus Repository admin **username** and **password**_ respectively, as set in [step 4](#step-4-prepare-nexus-repository).

### Step 6.4: Configure Tools for Jenkins
Go to _**Manage Jenkins** > **Tools**_ (under _**System Configuration** section_) and install the requried tools as described below.

#### Step 6.4.1: Add Java Development Kit
- Scroll down to the _**JDK installataions** section_.
- Click on _**Add JDK** button_.
- Enter a name in the _**Name** field_ as per your preference and note it down.
- Leave the **JAVA_HOME** field _blank_ and check the _**Install automatically** checkbox_.
- Click on the _**Add Installer** button_ and select the option "**Install from adoptium.net**" (requires [Eclipse Temurin Installer](https://plugins.jenkins.io/adoptopenjdk) plugin).
- Select Java version _17 or newer_ from the _**Version** dropdown_.

#### Step 6.4.2: Add SonarQube Scanner
- Scroll down to the _**SonarQube Scanner installations** section_ (requires [SonarQube Scanner](https://plugins.jenkins.io/sonar) plugin).
- Click on _**Add SonarQube Scanner** button_.
- Enter a name in the _**Name** field_ as per your preference and note it down.
- Ensure that the _**Install automatically** checkbox_ is checked.
- Select the **latest version of SonarQube** from the _Version_ dropdown under the _Install from Maven Central_ section.

#### Step 6.4.3: Add Maven
- Scroll down to the _**Maven installations** section_ (requires [Maven Integration](https://plugins.jenkins.io/maven-plugin) and [Pipeline Maven Integration](https://plugins.jenkins.io/pipeline-maven) plugins).
- Click on the _**Add Maven** button_.
- Enter a name in the _**Name** field_ as per your preference and note it down.
- Ensure that the _**Install automatically** checkbox_ is checked.
- Select the **latest version of Maven** from the _Version_ dropdown under the _Install from Apache_ section.

After configuring all the tools, scroll to the bottom of the page and click on _**Apply** button_ and then click on the _**Save** button_.

### Step 6.5: Configure Jenkins system settings
Go to _**Manage Jenkins** > **System**_ (under _**System Configuration** section_) and install the requried tools as described below.

#### Step 6.5.1: Configure SonarQube settings
- Scroll down to the _**SonarQube servers** section_ (requires requires [SonarQube Scanner](https://plugins.jenkins.io/sonar) plugin).
- Enable the _**Environment variables** checkbox_ and click on the _**Add SonarQube** button_.
- Enter a name in the _**Name** field_ as per your preference and note it down.
- Enter the **SonarQube web-interface URL** in the _**Server URL** field_ as per the _specified format_ in that section.
- Select the **SonarQube credentials** created in [step 6.2](#step-62-add-credentials) from the _**Server authenticaion** token dropdown_.

> [!NOTE]  
> The _Server authentication token_ dropdown might show the text entered in the _**Description** field_ of the Jenkins Credentials interface in step 6.2.  

#### [Optional] Step 6.5.2: Configure email notification
- Generate an "**App Password**" in your preferred email service provider for password-authentication over SMTP. Your provider may have a different name for the feature.
- Scroll down to the _**E-mail Notification** section_.
- Enter your provider's **SMTP server address** in the _**SMTP server** field_.
- Click on the _**Advanced** button_ to open advanced configurations.
- Enable the _**Use SMTP Authentication** checkbox_.
- Enter the _full email address_ and _password_ in the _**User Name**_ and _**Password**_ fields respectively.
- Enable _**Use SSL**_ and/or _**Use TLS**_ checkboxes as required by your provider.
- Specify the _port_ in the _**SMTP Port** field_ as per your requirement, otherwise it will _default to port 465_.
- Enter values as per your preference in the fields not mentioned above.
- Click on the _**Apply**_ and _**Save**_ buttons at the bottom of the page.

##### [Optional] Step 6.5.2a: Testing email notification
- Enable the checkbox labeled "**Test configuration by sending test e-mail**".
- Enter the _recipient email address_ in the _**Test e-mail recipient** field_.
- Click on the _**Test configuration** button_.

If configured properly, it will display the message "_Email was successfully sent_".

## Step 7: Prepare Jenkins build job
Prepare a Jenkins job for building and deploying the application by following the instructions below.

### Step 7.1: Create Jenkins pipeline job
- Open Jenkins dashboard/home page.
- Click on the _**Create a job** button_ in the centre, or the _**New Item** button_ in the _side-pane_ on the right.
- In the _**New Item** page_, enter a _name for the job_, then select _**Pipeline**_ under "_Select an item type_".
- Click on the _**OK** button_ at the bottom.

### Step 7.2: Configure pipeline job
- Open Jenkins dashboard/home page and click on your job from the list.
- In the _**Configure** page_ of the job, enter an appropriate description in the _**Description** field_ of the _**General** section_.
- Scroll down to the _**Triggers** section_ and _check the box_ for the option "**GitHub hook trigger for GITScm polling**".
- [Create a GitHub webhook](https://docs.github.com/en/webhooks/using-webhooks/creating-webhooks#creating-a-repository-webhook) with the values for the fields specified below.
	- **Payload URL**: `http://<jenkins-host-address>:8080/github-webhook/` ('`/`' is needed at the end)
	- **Content type**: `application/json`
	- **Which events would you like to trigger this webhook?**: `Send me everything`
	
	Unmentioned fields can be ignored or configured by preference.
- Click on _**Apply** button_ at the bottom.

### Step 7.3: Add the pipeline script
- Scroll down to the _**Pipeline** section_ of the job's _**Configure** page_.
- Select the option "**Pipeline script**" from the _**Definition** dropdown_.
- Copy the code from the file `Jenkins/Jenkinsfile` and paste inside the editor under "**Script**".
- Modify the variables in the pipeline script as specified below:
	- In the "_**`tools`**_" block, put the names of **JDK** and **Maven** tools _inside double-quotes_, as configured in previous steps [**6.4.1**](#step-641-add-java-development-kit) and [**6.4.3**](#step-643-add-maven) respectively.
		```groovy
		tools {
			jdk "JDK Tool Name"     // change as per your setup
			maven "Maven Tool Name" // change as per your setup
		}
		```
	- Provide the appropriate correct values for these critical vaiables in the "_**environment**_" block

| Header 1 | Header 2 |
|----------|----------|
| Row 1    | Cell A   |
| Row 2    | _        |
|          | Cell B   |

<table>
  <tr>
    <td>One</td>
    <td>Two</td>
  </tr>
  <tr>
    <td colspan="2">Three</td>
  </tr>
</table>

<table>
  <tr>
    <td>One</td>
    <td>Two</td>
  </tr>
  <tr>
    <td rowspan="2">Three</td>
  </tr>
</table>


`GIT_REPO_URL   `: 
`GIT_BRANCH_NAME`: 
`SONARQUBE_SERVER_NAME`: 
`MAVEN_GLOBAL_SETTINGS_CONFIG`: 



TRIVY_FILES_DIR       = "Trivy"
TRIVY_REPORTS_DIR     = "${env.TRIVY_FILES_DIR}/reports"
TRIVY_TEMPLATE_URL    = "https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl"
TRIVY_TEMPLATE_FILE   = "${env.TRIVY_FILES_DIR}/trivy-template.tpl"
TRIVY_FS_REPORT_FILE  = "trivy-fs-report.html"
TRIVY_FS_REPORT_NAME  = "Trivy File-system Scan Report"
TRIVY_BLD_REPORT_FILE = "trivy-bld-report.html"
TRIVY_BLD_REPORT_NAME = "Trivy Build Scan Report"
TRIVY_IMG_REPORT_FILE = "trivy-img-report.html"
TRIVY_IMG_REPORT_NAME = "Trivy Image Scan Report"

`DOCKER_NAMESPACE`: 
`DOCKER_REPOSITORY`: 
`DOCKER_IMAGE_TAG`: 
`DOCKER_IMAGE_NAME`: 
`DOCKER_CRED_ID`: 
`DOCKER_REPO_URL`: 
`DOCKERFILE_PATH`: 

AWS_REGION  = "ap-south-1"
AWS_CRED_ID = "AWS-Credentials"
EKS_CLUSTER_NAME = "BoardGame-Deployment-Cluster"

PASS_MAIL_FROM  = "sender@mail.com" // Email ID of sender. Use if configured sender ID is different. REMOVE IF NOT NEEDED.
PASS_MAIL_TO    = "abc@mail.com"
PASS_MAIL_CC    = "efg@mail.com"
PASS_MAIL_BCC   = "hij@mail.com"
PASS_MAIL_REPLY = "receiver@mail.com" // Used in the field "replyTo". REMOVE IF NOT NEEDED.
PASS_MAIL_SUBJ  = "Build SUCCESSFUL notification"
PASS_MAIL_BODY  = "Hello, this email is to notify the successful build and deployment."
FAIL_MAIL_FROM  = "sender@mail.com" // Email ID of sender. Use if configured sender ID is different. REMOVE IF NOT NEEDED.
FAIL_MAIL_TO    = "xyz@mail.com"
FAIL_MAIL_CC    = "uvw@mail.com"
FAIL_MAIL_BCC   = "rst@mail.com"
FAIL_MAIL_REPLY = "receiver@mail.com" // Used in the field "replyTo". REMOVE IF NOT NEEDED.
FAIL_MAIL_SUBJ  = "Build FAILURE notification"
FAIL_MAIL_BODY  = "Hello, this email is to notify the failure of build and deployment."