resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "OAI for S3 bucket for ${aws_s3_bucket.this-bucket.id}"
}

resource "aws_cloudfront_distribution" "elb_distro" {
  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    domain_name = aws_elb.elb.dns_name
    origin_id   = "my-elb"
  }

  origin {
    domain_name = aws_s3_bucket.this-bucket.bucket_regional_domain_name
    origin_id   = "my-s3"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Some comment"

  // domain aliases
  aliases = local.aliases

  // default cache behaviour
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my-elb"

    forwarded_values {
      headers      = [ "X-Header-Foo", "X-header-bar"]
      query_string = false

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type   = "origin-response"
      include_body = false
      lambda_arn   = "${aws_lambda_function.origin_function_response.qualified_arn}"
    }

    lambda_function_association {
      event_type   = "origin-request"
      include_body = true
      lambda_arn   = "${aws_lambda_function.origin_function_request.qualified_arn}"
    }

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = true
      lambda_arn   = "${aws_lambda_function.viewer_function_request.qualified_arn}"
    }

    lambda_function_association {
      event_type   = "viewer-response"
      include_body = false
      lambda_arn   = "${aws_lambda_function.viewer_function_response.qualified_arn}"
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/by-header"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "my-elb"

    forwarded_values {
      query_string = false
      headers      = ["User-Agent", "X-Foo"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/assets/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "my-s3"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  // It can be aloow or block
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "BR", "IE"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
  }
}