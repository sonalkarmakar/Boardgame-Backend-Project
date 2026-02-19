# Select the default VPC of the region
data "aws_vpc" "default" {
	region  = var.infra_region
	default = true
}
# Select the default Subnet of the VPC
data "aws_subnet" "default" {
	region = var.infra_region
	vpc_id = data.aws_vpc.default.id
}

# Define Security Group for the EC2 instances
resource "aws_security_group" "project_security_group" {
	region      = var.infra_region
	name_prefix = var.project_prefix

	tags = {
		Name = "${var.sg_name}" #"${var.project_prefix}-${var.sg_name}"
	}
}

# Define Inbound Rules for Security Group
resource "aws_security_group_rule" "inboun_access" {
	type              = "ingress"
	from_port         = var.inbound_access_port
	to_port           = var.inbound_access_port
	protocol          = "tcp"
	cidr_blocks       = [ "0.0.0.0/0" ]
	security_group_id = aws_security_group.project_security_group.id
}