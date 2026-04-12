variable "project_prefix" {
	description = "A prefix used for naming infrastructure components."
	type        = string
	default     = "BoardGame_Backend"
}

variable "username" {
	description = "Username of the IAM user for cluster management."
	type        = string
	default     = "cluster_admin"
}

variable "user_path" {
	description = "Path where the IAM user is created in AWS."
	type        = string
	default     = "/"
}

variable "display_name" {
	description = "Name shown in AWS Console for the IAM user."
	type        = string
	default     = "ClusterAdmin"
}

variable "user_purpose" {
	description = "Purpose of the IAM user to be shown as description in AWS Console."
	type        = string
	default     = "Administer Kubernetes cluster."
}

variable "managed_policies" {
	description = "Policies required by the IAM user for cluster administration."
	type        = list
	default     = [ 
		"AWSCloudFormationFullAccess",
		"AmazonEC2FullAccess",
	]
}

variable "inline_policies" {
	description = "Set of JSON files containing inline policies for IAM User."
	type        = map(string)
	default     = {}
}