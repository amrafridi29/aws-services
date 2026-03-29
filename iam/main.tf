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
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# The Role itself (with trust policy)
resource "aws_iam_role" "app_role" {
  name = "my-app-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    ManagedBy = "Terraform"
  }
}

# Attach AWS managed policy to the role
resource "aws_iam_role_policy_attachment" "app_role_s3" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Instance profile (wraps the role so EC2 can use it)
resource "aws_iam_instance_profile" "app_profile" {
  name = "my-app-instance-profile"
  role = aws_iam_role.app_role.name
}
