data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_route53_zone" "primary" {
  name = var.domain_name
}

data "aws_iam_role" "cloudfront_s3_access_role" {
  name = "cloudfront-s3-access-role"
}

data "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}

data "aws_api_gateway_resource" "root" {
  rest_api_id = data.aws_api_gateway_rest_api.api.id
  path = "/"
}