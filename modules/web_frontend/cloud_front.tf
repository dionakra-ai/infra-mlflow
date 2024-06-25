resource "aws_cloudfront_distribution" "frontend" {
    origin {
        domain_name = aws_s3_bucket.frontend.bucket_domain_name
        origin_id   = aws_s3_bucket.frontend.id

        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.frontend.cloudfront_access_identity_path
        }
    }

    aliases = var.urls

    enabled             = true
    is_ipv6_enabled     = true

    comment             = "origin das paginas do front do ${var.bucket_name}"

    default_root_object = var.default_root_object

    default_cache_behavior {
        allowed_methods  = ["HEAD", "GET", "OPTIONS"]
        cached_methods   = ["HEAD", "GET"]
        target_origin_id = aws_s3_bucket.frontend.id

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = var.min_ttl
        max_ttl                = var.max_ttl
        default_ttl            = var.default_ttl
    }

    price_class = var.price_class

    dynamic custom_error_response {
        for_each = var.enable_custom_error_response ? [true] : []

        content {
            error_caching_min_ttl = var.custom_error_response_error_caching_min_ttl
            error_code            = var.custom_error_response_error_code
            response_code         = var.custom_error_response_response_code
            response_page_path    = var.custom_error_response_response_page_path
        }
    }

    restrictions {
        geo_restriction {
            restriction_type = var.geo_restriction_restriction_type
            locations        = var.geo_restriction_locations
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = var.acm_certificate_arn == null
        acm_certificate_arn = var.acm_certificate_arn
        minimum_protocol_version = var.acm_certificate_arn != null ? "TLSv1.2_2021" : null
        ssl_support_method = var.acm_certificate_arn != null ? "sni-only" : null
    }

    tags = merge(
        {
            Name        = "frontend distribution do ${var.bucket_name}"
        },
        var.tags
    )
}

resource "aws_cloudfront_origin_access_identity" "frontend" {
    comment = "access-identity-frontend-${var.bucket_name}"
}