# S3 as backend

Then in your providers.tf add a backend block:

```
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state-20260401"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

```
