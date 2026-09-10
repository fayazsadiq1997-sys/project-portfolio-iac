output "vpc_id" {
  description = "ID of the VPC created in network module"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = [for subnet in aws_subnet.private_subnet : subnet.id]
}
