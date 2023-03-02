locals {
    # Use existing (via data source) or create new zone (will fail validation, if zone is not reachable)
    use_existing_route53_zone = true
    domain                    = "${var.app_name}-${var.env}.${(var.env == "test" ? "aws-test.sworks.com" : "aws.sworks.com")}"
}

data "aws_route53_zone" "sworks_net" {
    zone_id      = lookup(var.hosted_zone_id, var.env)
    private_zone = false
}

# -----------------------------------------------------------------------------------------------------------
# ACM public Certificate
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate
# -----------------------------------------------------------------------------------------------------------

resource "aws_acm_certificate" "app-cert" {
    domain_name = trimsuffix(local.domain, ".")
    #subject_alternative_names = ["sonarlab.sworks.net", "sonarlab.internal.sworks.net"]
    subject_alternative_names = var.acm_san
    validation_method = "DNS"

    lifecycle {
      create_befored_destroy = true
    }
}

# ------------------------------------------------------------------------------------------------------------
# Certificate validation request
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
# -------------------------------------------------------------------------------------------------------------

resource "aws_acm_certificate_validation" "app-cert-valid" {
    certificate_arn                 = aws_acm_certificate.app-cert.arn
    # validation_record_fqdns        = [ for record in aws_route53_record.sonar-record : record.fqdn]
    validation_record_fqdns         = [aws_route53_record.lb-cname-record[local.domain].fqdn, replace(aws_route53_record.lb-cname-record[var.acm_san[0]].fqdn, data.aws_route53_zone.sworks_net.name, ""), replace(aws_route53_record.lb-cname-record[var.acm_san[1]].fqdn, data.aws_route53_zone.sworks_net.name, "")]
    # validation_record_fqdns        = [aws_route53_record.lb-cname-record[local.domain].fqdn, replace(aws_route53_record.lb-cname-record[var.acm_san[0]].fqdn, data.aws_route53_zone.sworks_net.name, ""), replace(aws_route53_record.lb-cname-record[var.acm_san[1]].fqdn, data.aws_route53_zone.sworks_net.name, ""), aws_route53_record.lb-cname-record[var.acm_san[2]].fqdn, aws_route53_record.lb-cname-record[var.acm_san[3]].fqdn]
    timeouts {
      create = "60m"
    }
}

# -----------------------------------------------------------------------------------------------------------------
# Route53 record for domain validation request
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
# ------------------------------------------------------------------------------------------------------------------

resource "aws_route53_record" "lb-cname-record" {
    for_each = {
        for dvo in aws_acm_certificate.app-cert.domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            record = dvo.resource_record_value
            type   = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 60
    type            = "CNAME"
    zone_id         = data.aws_route53_zone.sworks_net.zone_id

}

# DNS
resource "aws_route53_record" "elb-DNS" {
    zone_id = data.aws_route53_zone.sworks_net.zone_id
    name    = "sonar"
    type    = "A"

    alias {
      name                    = trimsuffix(aws_lb.app-alb.dns_name, ".")
      zone_id                 = aws_lb.app-alb.zone_id
      evaluate_target_health  = true
    }
  
}