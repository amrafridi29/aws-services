resource "aws_iam_user" "developer" {
  name = "developer"

  tags = {
    Role      = "Developer",
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_policy" "s3_policy" {
  name        = "s3-read-only-policy"
  description = "Provides read-only access to S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:GetObject", "s3:ListBucket"],
      Resource = "*"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "developer_s3" {
    user = aws_iam_user.developer.name
    policy_arn = aws_iam_policy.s3_policy.arn
  
}
