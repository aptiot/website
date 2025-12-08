resource "aws_acm_certificate" "public_cert" {
  provider = aws.global
  domain_name               = "aptiot.hu"
  subject_alternative_names = [
    "*.aptiot.hu"
  ]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "CloudFront access identity for S3"
}

resource "aws_cloudfront_response_headers_policy" "http-cache-headers" {
  name = "http-cache-headers"
  custom_headers_config {
    items {
      header = "Cache-Control"
      override = false
      value = "no-cache"
    }
  }
}

resource "aws_cloudfront_distribution" "website" {
  http_version = "http2and3"
  enabled = true
  default_root_object = "index.html"
  is_ipv6_enabled = true
  price_class = "PriceClass_100"
  aliases = [local.domain_name]

  origin {
    domain_name = format("%s.s3.eu-north-1.amazonaws.com", local.s3_bucket_name)
    origin_id = format("%s.s3.eu-north-1.amazonaws.com", local.s3_bucket_name)
    connection_attempts = 3
    connection_timeout = 10
    origin_access_control_id = "EBMK8TUX648H5"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.public_cert.arn
    cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }
  default_cache_behavior {
    target_origin_id = format("%s.s3.eu-north-1.amazonaws.com", local.s3_bucket_name)
    allowed_methods  = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    cached_methods = ["GET", "HEAD"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress = true
    response_headers_policy_id = aws_cloudfront_response_headers_policy.http-cache-headers.id
    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = aws_lambda_function.hugo_url_rewrite.qualified_arn
    }
  }
}

resource "aws_cloudfront_distribution" "website_redirect" {
  http_version = "http2and3"
  enabled = true
  is_ipv6_enabled = true
  price_class = "PriceClass_100"
  aliases = [local.domain_name_redirect]

  origin {
    domain_name = format("%s.s3-website.eu-north-1.amazonaws.com", local.s3_bucket_name_redirect)
    origin_id = format("%s.s3-website.eu-north-1.amazonaws.com", local.s3_bucket_name_redirect)
    connection_attempts = 3
    connection_timeout = 10
    # origin_access_control_id = "EBMK8TUX648H5"
    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = [
        "SSLv3",
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.public_cert.arn
    cloudfront_default_certificate = false
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method = "sni-only"
  }
  default_cache_behavior {
    target_origin_id = format("%s.s3-website.eu-north-1.amazonaws.com", local.s3_bucket_name_redirect)
    allowed_methods  = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    cached_methods = ["GET", "HEAD"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress = true
  }
}