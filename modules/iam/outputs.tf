output "cloudfront_s3_access_role_arn" {
  value = aws_iam_role.cloudfront_access_identity.arn
}

output "iam_arn" {
  value = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
}