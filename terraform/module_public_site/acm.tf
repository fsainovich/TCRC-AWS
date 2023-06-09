# SSL Certificate from ACM configs

# Qyery for main R53 zone
data "aws_route53_zone" "main" {

  name         = var.domain_name
  private_zone = false

}

#Create ACM certificate
resource "aws_acm_certificate" "ssl_certificate" {

  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tags = var.common_tags

}

# R53 entries for validation
resource "aws_route53_record" "dns_records" {

  for_each = {
    for dvo in aws_acm_certificate.ssl_certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.main.id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id

}

# R53 validation to generate certificate
resource "aws_acm_certificate_validation" "cert_validation" {

  certificate_arn         = aws_acm_certificate.ssl_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_records : record.fqdn]  
  
}
