# -------------------------------------------------------------------------------------------------------
# Application loadbalancer https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# -------------------------------------------------------------------------------------------------------

resource "aws_lb" "app-alb" {
    name               = "${var.app_name}-${var.env}-lb"
    internal           = true
    load_balancer_type = "application"
    subnets            = var.private_subnets
    security_groups    = [aws_security_group.allow_sg_sonar_lb.id]

    enable_deletion_protection = false 
}

resource "aws_lb_listener" "app_listen_lb" {
    load_balancer_arn = aws_lb.app-alb.arn
    port              = var.lb_port
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = aws_acm_certificate_validation.app-cert-valid.certificate_arn

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.alb-target-group.arn
    }
}

resource "aws_lb_target_group" "alb-target-group" {
    name        = "sonaraws-alb-target-${var.env}"
    port        = var.app_port
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    stickiness {
        type = "lb_cookie"
    }
    # Alter the destination of the health check to be the login page.
    health_check {
        path     = "/login"
        port     = var.app_port
        protocol = "HTTP"
        timeout  = 5
        interval = 10
    }
  
}

resource "aws_lb_target_group_attachment" "lb-target-attach" {
    target_group_arn = aws_lb_target_group.alb-target-group.arn
    target_id        = var.ec2_instance_id
    port             = var.app_port
}