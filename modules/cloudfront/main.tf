locals {
  s3_origin_id = "${var.bucket_name}-origin"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = var.origin_domain_name
    origin_id = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled = true
  is_ipv6_enabled = true
  comment = "Static website hosting"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = [ "GET", "HEAD" ]
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 864-00
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


    price_class = "PriceClass_100"

    viewer_certificate {
        acm_certificate_arn = var.certificate_arn
        ssl_support_method = "sni-only"
    }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "S3 origin access identity"
}