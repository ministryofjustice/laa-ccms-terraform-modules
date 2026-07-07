resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids

  drop_invalid_header_fields = true
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = "${var.name}-alb"
  })
}

resource "aws_lb_target_group" "alb" {
  name                 = "${var.name}-tg"
  port                 = var.target_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check.path
    matcher             = var.health_check.matcher
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    interval            = var.health_check.interval
    timeout             = var.health_check.timeout
    protocol            = "HTTP"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name}-listener"
  })
}
