output "public_ip" {
	description = "Public IP address of the EC2 instance."
	value       = aws_instance.compute_instance.public_ip
}

output "instance_id" {
	description = "EC2 Instance ID."
	value       = aws_instance.compute_instance.id
}