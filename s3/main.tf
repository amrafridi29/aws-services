
# ─── S3 Bucket ──────────────────────────────────────────────
resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = false

  tags = {
    Name = var.bucket_name
  }
}

# ─── Block All Public Access ─────────────────────────────────
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── Enable Versioning ───────────────────────────────────────
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ─── Server-Side Encryption ──────────────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# ─── Lifecycle Rules ─────────────────────────────────────────
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  rule {
    id     = "move-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

# ─── Upload a Sample Object ──────────────────────────────────
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.main.id
  key          = "static-site/index.html"
  content      = "<h1>Hello from S3!</h1>"
  content_type = "text/html"

  tags = {
  }
}
