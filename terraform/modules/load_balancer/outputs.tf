output "lb_DNSname" {
    value = aws_lb.app-alb.dns_name
}

output "cert_arn" {
    value = aws_acm_certificate_validation.app-cert-valid.certificate_arn
}