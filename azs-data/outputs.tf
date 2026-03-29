output "available_zones" {
  description = "All available zones"
  value       = data.aws_availability_zones.available.names[*]
}

output "current_region" {
  description = "The name of the current region"
  value       = data.aws_region.current.name
}

output "account_id" {
  description = "Caller account identity"
  value       = data.aws_caller_identity.current.account_id
}
