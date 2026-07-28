provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "etl-snowflake-demo-johan"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "folders" {
  for_each = toset(["raw/", "processed/", "curated/"])
  bucket   = aws_s3_bucket.data_bucket.id
  key      = each.value
}

output "bucket_name" {
  value = aws_s3_bucket.data_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.data_bucket.arn
}

