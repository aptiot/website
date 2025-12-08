terraform {
  backend "s3" {
    bucket = "aptiot-tfstate"
    key    = "website.tfstate"
    region = "eu-north-1"
  }
  required_providers {
    aws = {
      source  = "opentofu/aws"
      version = "~> 5.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

locals {
  root_domain = "aptiot.hu"
  s3_bucket_name = "www.${local.root_domain}"
  s3_bucket_name_redirect = local.root_domain
  domain_name = "www.${local.root_domain}"
  domain_name_redirect = local.root_domain
  github_actions_arn = "arn:aws:iam::180294196620:user/github"
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
}
provider "aws" {
  alias = "global"
  region = "us-east-1"
}
