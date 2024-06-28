output "s3_bucket_website_endpoint" {
  value = module.s3_bucket.bucket_website_endpoint
}

# output "cloudfront_domain_name" {
#   value = module.cloudfront.cloudfront_domain_name
# }

# output "iam_role_arn" {
#   value = module.iam.cloudfront_s3_access_role_arn
# }

# output "certificate_arn" {
#   value = module.certificate.certificate_arn
# }

# output "route53_domain_name" {
#   value = module.route53.domain_name
# }