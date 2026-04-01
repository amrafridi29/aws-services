variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique name for the S3 bucket"
  type        = string
  default     = "myapp-assets-2024-unique-suffix"
}
