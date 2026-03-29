
output "vpc_id" {
  description = "The ID of our VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The IP range of our VPC"
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "AZs available in our region"
  value       = data.aws_availability_zones.available.names
}
