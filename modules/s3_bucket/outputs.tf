output "bucket_arn" {
  value = aws_s3_bucket.wave.arn
}

output "bucket_website_endpoint" {
  value = aws_s3_bucket_website_configuration.wave.website_endpoint
}