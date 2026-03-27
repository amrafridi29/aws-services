output "developer_arn" {
  description = "The ARN of the developer IAM user"
  value       = aws_iam_user.developer.arn
}

output "policy_arn" {
  description = "The ARN of the S3 read policy"
  value       = aws_iam_policy.s3_policy.arn
}
