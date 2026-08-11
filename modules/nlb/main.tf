resource "aws_lb" "nlb" {
  name               = "${var.name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  security_groups    = var.security_group_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = "${var.name}-nlb"
  })
}

resource "aws_lb_target_group" "nlb" {
  name                 = "${var.name}-tg"
  port                 = var.target_port
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay

  health_check {
    protocol            = var.health_check.protocol
    path                = var.health_check.path
    port                = coalesce(var.health_check.port, var.target_port)
    matcher             = var.health_check.matcher
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    interval            = var.health_check.interval
    timeout             = var.health_check.timeout
  }

  tags = merge(var.tags, {
    Name = "${var.name}-tg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Port 80 TCP passthrough
resource "aws_lb_listener" "tcp80" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name}-listener-80"
  })
}

# Port 443 TLS, terminated at the NLB using the shared wildcard cert
resource "aws_lb_listener" "tls443" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 443
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name}-listener-443"
  })
}

# Direct TCP passthrough on the app's own server port
resource "aws_lb_listener" "target_port" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.target_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb.arn
  }

  tags = merge(var.tags, {
    Name = "${var.name}-listener-${var.target_port}"
  })
}
