provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_s3_bucket" "wave" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "wave" {
  bucket = aws_s3_bucket.wave.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}

resource "aws_s3_bucket_policy" "wave" {
  bucket = aws_s3_bucket.wave.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AllowGetObjects"
    Statement = [
      {
        Sid       = "AllowPublic"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.wave.arn}/**"
      }
    ]
  })
}

resource "aws_s3_object" "upload_object" {
  for_each      = fileset("html/", "*")
  bucket        = aws_s3_bucket.wave.id
  key           = each.value
  source        = "html/${each.value}"
  etag          = filemd5("html/${each.value}")
  content_type  = "text/html"
}