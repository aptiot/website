resource "aws_s3_bucket" "website" {
  for_each = toset([local.s3_bucket_name, local.s3_bucket_name_redirect])
  bucket = each.key
}

resource "aws_s3_bucket_website_configuration" "website_redirect" {
  bucket = aws_s3_bucket.website[local.s3_bucket_name_redirect].id
  redirect_all_requests_to {
    host_name = local.domain_name
    protocol = "https"
  }
}

data "aws_iam_policy_document" "allow_cdn_origin_access" {
  statement {
    principals {
      type          = "Service"
      identifiers   = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.website["www.aptiot.hu"].arn}/*",
    ]
    condition {
      test          = "ForAnyValue:StringEquals"
      variable      = "AWS:SourceArn"
      values        = [aws_cloudfront_distribution.website.arn]
    }
  }
  statement {
    principals {
      type          = "AWS"
      identifiers   = [local.github_actions_arn]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.website["www.aptiot.hu"].arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "allow_cdn_origin_access_redirect" {
  statement {
    principals {
      type          = "Service"
      identifiers   = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.website["aptiot.hu"].arn}/*",
    ]
    condition {
      test          = "ForAnyValue:StringEquals"
      variable      = "AWS:SourceArn"
      values        = [aws_cloudfront_distribution.website_redirect.arn]
    }
  }
  statement {
    principals {
      type          = "AWS"
      identifiers   = [local.github_actions_arn]
    }
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.website["aptiot.hu"].arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_cdn_origin_access" {
  bucket            = aws_s3_bucket.website["www.aptiot.hu"].id
  policy            = data.aws_iam_policy_document.allow_cdn_origin_access.json
}

resource "aws_s3_bucket_policy" "allow_cdn_origin_access_redirect" {
  bucket            = aws_s3_bucket.website["aptiot.hu"].id
  policy            = data.aws_iam_policy_document.allow_cdn_origin_access_redirect.json
}
