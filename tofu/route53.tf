locals {
  domain = ["www.aptiot.hu"]
  domain_redirect = ["aptiot.hu"]
  record_types = ["A", "AAAA"]
  domain_record_types = [
    for pair in setproduct(local.domain, local.record_types) : {
      domain_name = pair[0]
      record_type = pair[1]
    }
  ]
  domain_record_types_redirect = [
    for pair in setproduct(local.domain_redirect, local.record_types) : {
      domain_name = pair[0]
      record_type = pair[1]
    }
  ]
}

resource "aws_route53_zone" "aptiot" {
  name = "aptiot.hu"

  tags = {
    brand = "aptiot"
  }
}

resource "aws_route53_record" "website" {
  for_each = {
    for record in local.domain_record_types : "${record.domain_name}-${record.record_type}" => [record.domain_name, record.record_type]
  }
  zone_id = aws_route53_zone.aptiot.zone_id
  name    = each.value[0]
  type    = each.value[1]

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "website_redirect" {
  for_each = {
    for record in local.domain_record_types_redirect : "${record.domain_name}-${record.record_type}" => [record.domain_name, record.record_type]
  }
  zone_id = aws_route53_zone.aptiot.zone_id
  name    = each.value[0]
  type    = each.value[1]

  alias {
    name                   = aws_cloudfront_distribution.website_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.website_redirect.hosted_zone_id
    evaluate_target_health = true
  }
}