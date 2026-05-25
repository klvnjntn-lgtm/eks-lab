output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnets" {
  description = "List of IDs of subnets (Using public subnets to avoid NAT Gateway costs)"
  value       = aws_subnet.public[*].id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "interface_endpoint_ids" {
  description = "The IDs of the VPC Interface Endpoints"
  value = [for endpoint in aws_vpc_endpoint.interface : endpoint.id]
}