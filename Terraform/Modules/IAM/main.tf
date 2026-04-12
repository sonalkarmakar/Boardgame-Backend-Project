# Create the cluster admin IAM User
resource "aws_iam_user" "cluster_admin" {
	name = var.username
	path = var.user_path

	tags = {
		Name    = var.display_name
		Purpose = var.user_purpose
	}
}

# Attach necessary policies to IAM User
resource "aws_iam_user_policy_attachment" "managed" {
	user       = aws_iam_user.cluster_admin.name
	for_each   = toset(var.managed_policies)
	policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

# Get the AWS Account ID
data "aws_caller_identity" "current" {}

resource "aws_iam_user_policy" "inline_policy" {
	for_each = var.inline_policies
	name     = each.key
	user     = aws_iam_user.cluster_admin.name
	policy   = templatefile(each.value, { account_id = data.aws_caller_identity.current.account_id })
}

# Generate Access Key for the IAM User
resource "aws_iam_access_key" "eks_admin_key" {
	user = aws_iam_user.cluster_admin.name
}