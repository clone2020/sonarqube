resource "aws_security_group" "sg_sonarqube_rds" {
    name = "sg_sonarqube_${var.env}"

    description = "RDS postgres servers (terraform-managed)"
    vpc_id      = var.vpc_id

    # Only postgres in
    ingress {
        from_port   = var.db_port
        to_port     = var.db_port
        protocol    = "tcp"
        cidr_blocks = var.scwx_internal_cidr_blocks
    }

    # Allow all outbound traffic.
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = var.scwx_internal_cidr_blocks
    }
  
}