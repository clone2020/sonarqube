resource "aws_security_group" "allow_sg_sonar" {
    name          = "allow_sg_sonar_${var.env}"
    description   = "Allow TLS and SSH inbound traffic"
    vpc_id        = var.vpc_id

    ingress {
        from_port   = var.ssh_port
        to_port     = var.ssh_port
        protocol    = "tcp"
        cidr_blocks = var.scrx_internal_cidr_blocks
    }

    ingress {
        description = "TLS from VPC"
        from_port   = var.app_port
        to_port     = var.app_port
        protocol    = "tcp"
        cidr_blocks = var.scrx_internal_cidr_blocks
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        #cidr_blocks = var.scwx_internal_cidr_blocks
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}