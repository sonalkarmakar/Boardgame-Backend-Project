# Decommissioning Process
There are 2 stages for decommissioning all the infrastucture created for this project:
- Delete the AWS Elastic Kubernetes Service cluster.
- Destroying the resources provisioned by Terraform.

## Prerequisite
The project has to be deployed once for you to be able to follow the decommissioning steps.

> [!IMPORTANT]  
> Deleting the EKS cluster and destroying the resource provisioned by Terraform are _mutually independent_.  
> However, destroying the Terraform resources will also **destroy the setup that can delete the EKS cluster**.  
> For smooth operation, ensure that the **EKS cluster is deleted _before_ destroying Terraform-provisioned resources**.  
>   
> In case the resources provisioned by Terraform are destroyed _before_ deleting the cluster,  
> - Get a system for deleting EKS cluster and install [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [`eksctl`](https://docs.aws.amazon.com/eks/latest/eksctl/installation.html), and [`kubectl`](https://k8s-docs.netlify.app/en/docs/tasks/tools/install-kubectl/).  
> - If it's not done already, [generate an AWS Access Key](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-key-self-managed.html#Using_CreateAccessKey) for your AWS Account that **can delete EKS clusters**.
> - **Configure AWS CLI v2 to use your AWS account** with EKS cluster deletion privilege:
> 	- Run the command `aws configure`.
> 	- Enter the _access key ID_ of your AWS account.
> 	- Enter the _access key Secret_.
> 	- Enter your cluster's [_AWS Region code_](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints) for this project.
> 	- Enter your preferred [_output format_](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-output-format.html).

## Deleting EKS Cluster
> [!WARNING]  
> **Avoid _manually deleting_ EKS cluster resources from the _AWS Console_.** It's much easier to delete them using the `eksctl` tool.  
> - Network resources can't be deleted unless nothing is using them.  
> - Clusters can't be deleted unless no application is active in them.  
> - Cluster nodes can't be deleted because they're self-healing, unless minimum and maximum number of nodes reduced to 0.  

- <ins>_Step 1:_</ins> Login to the **Control Node** EC2 instance.
- <ins>_Step 2:_</ins> Ensure that the the **Kubernetes maifest files** (YAML files defining the Kubernetes resources) of the project are present in the instance.
	- If they're not present, copy them to the instance from the repository clone in your system.
		```sh
		scp -i <repo-path>/Terraform/.secrets/BoardGame_Backend-EC2_SSH_key.pem -P 443 -r <repo-path>/Kubernetes/ ubuntu@<ControlNode-Public-IP>:~/
		```
> [!NOTE]  
> The file and directory names above are the default values set for this project.  
> Change the names of _"`.secrets`" directory_ and _"`BoardGame_Backend-EC2_SSH_key.pem`" private key_ to what you've set in the "**`terraform.tfvars`**" file.  

- <ins>_Step 3:_</ins> Delete the **Kubernetes resources** from the **EKS cluster** using the YAML manifests.
	```sh
	kubectl delete -f /path/to/kubernetes-folder
	```
	Wait for the command to finish execution.
- <ins>_Step 4:_</ins> **Delete the EKS cluster** using `eksctl` command below and wait for it to finish executing, it takes a while.
	```sh
	eksctl delete cluster --name <CLUSTER_NAME> --region <CLUSTER_REGION>
	```
	- `<CLUSTER_NAME>` is the name given to the EKS cluster.
	- `<CLUSTER_REGION>` is the AWS region where the cluster is deployed.
- <ins>_Step 5:_</ins> Verify that the cluster has been deleted from the AWS Console
	- [_EKS Clusters_](https://console.aws.amazon.com/eks/clusters) page shows any **currently active EKS clusters**.
	- [_CloudFormation_](https://console.aws.amazon.com/cloudformation/home/stacks) page shows **cloud stacks assigned** to any active resources, like EKS clusters.
	- [_EC2 Instances_](https://console.aws.amazon.com/ec2/#Instances:) page shows the **cluster node instances**.
	- [_Elastic IP addresses_](https://console.aws.amazon.com/ec2/#Addresses:) page shows any **elastic IP address assigned** to any EC2 instances.
	- Also check the [_VPC Console_](https://console.aws.amazon.com/vpcconsole/) for any newly created **VPCs with the cluster's name**.

> [!NOTE]  
> Ensure that the AWS Console is set to the **_correct AWS Region_** for all the pages mentioned above.  

## Destroying resources provisioned by Terraform
- <ins>_Step 1:_</ins> Open a temrinal in the system you used to create the resources with Terraform.
- <ins>_Step 2:_</ins> Go inside the "`Terraform`" directory of the respository clone in your system.
	```sh
	cd /path/to/repo/clone/Terraform
	```
- <ins>_Step 3:_</ins> Run the command below to destroy the provisioned resources. Remove the flag "_`-auto-approve`_" if you wish manually approve each deletion.
	```sh
	terraform destroy -auto-approve
	```
- <ins>_Step 4:_</ins> Restore the placeholder `pom.xml` and `Ansible/inventory.ini` files.
	- Get the ID of the commit that you know has the files before the Terraform resource provisioning
		```sh
		git log --oneline
		```
	- Checkout the files using the commit ID
		```sh
		git checkout -- <commit-id> /path/to/pom.xml /path/to/Ansible/inventory.ini
		```
	- Commit the change to the `pom.xml`.
		```sh
		git add /path/to/pom.xml
		git commit -m "Restoring placeholder/template pom.xml"
		```

## Unaffected items
If the deployment is done at least once, and then the infrastructure resources are decommissioned, then the following items will remain unaffected after decommissioning:
- Docker Hub image of the application.