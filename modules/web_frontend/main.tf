resource "aws_s3_bucket_public_access_block" "frontend" {
    bucket = aws_s3_bucket.frontend.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket" "frontend" {
    bucket = var.bucket_name
    acl    = "private"

    policy = templatefile("${path.module}/bucket_policy.json", {
        bucket_name = var.bucket_name
        OAI = aws_cloudfront_origin_access_identity.frontend.id
    })

    tags = merge(
        {
            Name        = "frontend bucket ${var.bucket_name}"
        },
        var.tags
    )
}