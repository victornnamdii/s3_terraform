module "s3_bucket" {
  source          = "../modules/s3_bucket"
  region = var.region
  bucket_name     = var.bucket_name
  # origin_access_identity = module.iam.iam_arn
  access_key = var.access_key
  secret_key = var.secret_key
}

module "iam" {
  source        = "../modules/iam"
  s3_bucket_arn = module.s3_bucket.bucket_arn
}

module "certificate" {
  source            = "../modules/certificate"
  domain_name       = var.domain_name
  alternative_names = var.alternative_names
  zone_id           = data.aws_route53_zone.primary
  tags              = var.tags
}

module "cloudfront" {
  source              = "../modules/cloudfront"
  region = var.region
  bucket_name = var.bucket_name
  origin_domain_name  = module.s3_bucket.bucket_website_endpoint
  certificate_arn     = module.certificate.certificate_arn
}

module "route53" {
  source                 = "../modules/route53"
  domain_name            = var.domain_name
  zone_id                = data.aws_route53_zone.primary
  cloudfront_domain_name = module.cloudfront.cloudfront_domain_name
}

module "api_gateway_config" {
  source        = "../modules/api_gateway/config"
  api_name      = var.api_name
  api_description = var.api_description
  stage_name    = var.api_stage
  tags          = var.tags
}

module "api_gateway_resources" {
  source             = "../modules/api_gateway/resources"
  api_id             = module.api_gateway_config.api_id
  parent_id          = data.aws_api_gateway_resource.root.id
  path_part          = var.path_part
  http_method        = var.http_method
  authorization      = var.authorization
  request_parameters = var.request_parameters
  integration_uri    = var.integration_uri
  request_templates  = var.request_templates
  additional_methods = var.additional_methods
}