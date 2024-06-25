resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.name


   tags = merge(
    {
      Name        = var.name
    },
    merge(var.tags)
  )
   
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      
      sse_algorithm     = "AES256"
    }
  }
}