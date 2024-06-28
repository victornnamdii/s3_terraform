resource "aws_iam_role" "cloudfront_access_identity" {
  name = "cloudfront-access-identity-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "cloudfront.amazonaws.com"
            }
        }
    ]
  })
}

resource "aws_iam_role_policy" "cloudfront_s3_access_policy" {
  name = "cloudfront-s3-access-policy"
  role = aws_iam_role.cloudfront_access_identity.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "s3:GetObject",
                "s3:ListBucket"
            ]
            Resource = [
                var.s3_bucket_arn,
                "${var.s3_bucket_arn}/*"

            ]
        }
    ]
  })
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin access identity for S3"
}