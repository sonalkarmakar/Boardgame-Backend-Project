# Select the default VPC of the region
data "aws_vpc" "default" {
	region  = var.infra_region
	default = true
}

# Define Security Group for the EC2 instances
resource "aws_security_group" "project_security_group" {
	region      = var.infra_region
	name_prefix = var.project_prefix

	tags = {
		Name = "${var.project_prefix}-${var.sg_name}"
	}
}

# Define Inbound Rules for Security Group
resource "aws_security_group_rule" "inbound_access" {
	for_each = var.inbound_access_port
	
	type              = "ingress"
	from_port         = each.value
	to_port           = each.value
	protocol          = "tcp"
	cidr_blocks       = [ "0.0.0.0/0" ]
	security_group_id = aws_security_group.project_security_group.id
}

# Define Outbound Rule for Security Group
resource "aws_security_group_rule" "outbound_access" {
	type              = "egress"
	from_port         = 0
	to_port           = 0
	protocol          = "-1"
	cidr_blocks       = [ "0.0.0.0/0" ]
	security_group_id = aws_security_group.project_security_group.id
}