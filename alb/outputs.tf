output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of all public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of all private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of all public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_azs" {
  description = "AZs of each public subnet"
  value       = aws_subnet.public[*].availability_zone
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of all NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "Public Elastic IPs of all NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "alb_security_group_id" {
  description = "Security Group ID for the load balancer"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security Group ID for app servers"
  value       = aws_security_group.app.id
}

output "bastion_security_group_id" {
  description = "Security Group ID for bastion host"
  value       = aws_security_group.bastion.id
}

output "db_security_group_id" {
  description = "Security Group ID for databases"
  value       = aws_security_group.db.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "app_server_private_ip" {
  description = "Private IP of the app server"
  value       = aws_instance.app.private_ip
}

output "ami_id" {
  description = "AMI ID used for instances"
  value       = data.aws_ami.amazon_linux.id
}

output "app_data_volume_id" {
  description = "ID of the app data EBS volume"
  value       = aws_ebs_volume.app_data.id
}

output "app_data_volume_arn" {
  description = "ARN of the app data EBS volume"
  value       = aws_ebs_volume.app_data.arn
}

output "snapshot_id" {
  description = "ID of the data volume snapshot"
  value       = aws_ebs_snapshot.app_data_backup.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the app target group"
  value       = aws_alb_target_group.app.arn
}
