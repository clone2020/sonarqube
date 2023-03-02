############# Security groups ###########

resource "aws_security_group" "allow_sg_sonar_lb" {
    name        = "allow_sg_sonar_lb_${var.env}"
    description = "Allow TLS/SSL inbound traffic"
    vpc_id      = var.vpc_id  

    ingress = [ {
      cidr_blocks = var.scwx_internal_cidr_blocks
      description = "TLS from VPC"
      from_port   = var.lb_port
      to_port     = var.lb_port
      protocol    = "tcp"
    } ]

    egress = [ {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = var.scwx_internal_cidr_blocks
    } ]
}