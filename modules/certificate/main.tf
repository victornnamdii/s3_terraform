resource "aws_acm_certificate" "website_certificate" {
  domain_name = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.alternative_names

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website_certificate.domain_validation_options : dvo.domain_name => {
        name = dvo.resource_record_name
        type = dvo.resource_record_type
        value = dvo.resource_record_value
        zone_id = var.zone_id
    }
  }

  name = each.value.name
  type = each.value.type
  zone_id = each.value.zone_id
  records = [ each.value.value ]
  ttl = 300
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn = aws_acm_certificate.website_certificate.arn
  validation_record_fqdns = [ for record in aws_route53_record.certificate_validation : record.fqdn ]
}