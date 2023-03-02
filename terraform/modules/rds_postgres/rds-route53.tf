locals {
    # Use existing (via data source) or create new zone (will fail validation, if zone is not reachable)
    use_existing_route53_zone = true
}

resource "aws_route53_record" "database" {
    zone_id = lookup(var.hosted_zone_id, var.env)
    name = "${var.app_name}-${var.env}-database.${lookup(var.domain, var.env)}"
    type = "CNAME"
    ttl = "300"
    records = ["${aws_db_instance.rds_instance.address}"]
}
