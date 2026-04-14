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

resource "aws_vpc_security_group_ingress_rule" "inbound_access" {
	for_each = var.inbound_access_port
	
	from_port         = each.value
	to_port           = each.value
	ip_protocol       = "tcp"
	cidr_ipv4         = "0.0.0.0/0"
	security_group_id = aws_security_group.project_security_group.id

	tags = {
		Name = each.key
	}
}

resource "aws_vpc_security_group_egress_rule" "outbound_access" {
	ip_protocol       = "-1"
	cidr_ipv4         = "0.0.0.0/0"
	security_group_id = aws_security_group.project_security_group.id

	tags = {
		Name = "AllAccess"
	}
}