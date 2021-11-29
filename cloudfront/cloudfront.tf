provider "aws" {
  version                                = ">= 1.2.0"
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

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"

  aliases = ["cf-demo.rondi.ninja"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "my-elb"

    forwarded_values {
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

  price_class = "PriceClass_200"

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
    acm_certificate_arn = "arn:aws:acm:us-east-1:112574856804:certificate/8096431b-48ce-48aa-ae0d-4e38a1676229"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
  }
}