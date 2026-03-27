output "security_group_id" {
	description = "ID of the Security Group."
	value       = aws_security_group.project_security_group.id
}

output "external_access_ports" {
	description = "List of ports available for accessing specific applications."
	value = {
		for k, v in aws_vpc_security_group_ingress_rule.inbound_access :
			v.tags.Name => v.from_port
	}
}