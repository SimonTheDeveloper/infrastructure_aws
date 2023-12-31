provider "aws" {
  region = "eu-west-2" # Replace with your desired AWS region
}

resource "aws_s3_bucket" "prod_media" {
  bucket = "kamia-consulting-finance-data-bucket"
}

resource "aws_s3_bucket_cors_configuration" "prod_media" {
  bucket = aws_s3_bucket.prod_media.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_acl" "prod_media" {
  bucket = aws_s3_bucket.prod_media.id
  acl    = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.prod_media.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_iam_policy" "create_user_policy" {
  name        = "my_unique_create_user_policy"
  description = "My unique IAM policy for creating users"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "iam:CreateUser",
        Effect   = "Allow",
        Resource = "*",
      },
      // Add other statements for additional permissions if needed
    ],
  })
}

resource "aws_iam_user" "aws_infrastructure" {
  name = "aws_infrastructure"
  
  # Attach the IAM policy to the user for creating IAM users
  permissions_boundary = aws_iam_policy.create_user_policy.arn
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.prod_media.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
