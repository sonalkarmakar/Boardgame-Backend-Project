output "eks_admin_key_id" {
	description = "Access Key ID of the cluster admin IAM user."
	sensitive   = true
	value       = aws_iam_access_key.eks_admin_key.id
}

output "eks_admin_key_secret" {
	description = "Access Key Secret of the cluster admin IAM user."
	sensitive   = true
	value       = aws_iam_access_key.eks_admin_key.secret
}