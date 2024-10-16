resource "aws_lb" "sample_alb" {
  name               = "sample-${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups = [var.alb_sg_id]

  tags = {
    Name = "sample-${var.prefix}-alb"
  }
}

resource "aws_lb_target_group" "sample_alb_tg_5502" {
  name        = "sample-${var.prefix}-alb-tg-5502"
  port        = 5502
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    matcher             = "200-499"
  }

  tags = {
    Name = "sample-${var.prefix}-alb-tg-5502"
  }
}

resource "aws_lb_listener" "sample_alb_listener_5502" {
  load_balancer_arn = aws_lb.sample_alb.arn
  port              = 5502
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "sample_alb_listener_5502_health_rule" {
  listener_arn = aws_lb_listener.sample_alb_listener_5502.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_alb_tg_5502.arn
  }

  condition {
    source_ip {
      values = [var.cidr_block]
    }
  }
}

resource "aws_lb_listener_rule" "sample_alb_listener_5502_host_rule" {
  listener_arn = aws_lb_listener.sample_alb_listener_5502.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_alb_tg_5502.arn
  }

  condition {
    host_header {
      values = ["sample.${var.prefix}.game.api.richalien.net"]
    }
  }
}

resource "aws_lb_target_group" "sample_alb_tg_5503" {
  name        = "sample-${var.prefix}-alb-tg-5503"
  port        = 5503
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    matcher             = "200-499"
  }

  tags = {
    Name = "sample-${var.prefix}-alb-tg-5503"
  }
}

resource "aws_lb_listener" "sample_alb_listener_5503" {
  load_balancer_arn = aws_lb.sample_alb.arn
  port              = 5503
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "sample_alb_listener_5503_health_rule" {
  listener_arn = aws_lb_listener.sample_alb_listener_5503.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_alb_tg_5503.arn
  }

  condition {
    source_ip {
      values = [var.cidr_block]
    }
  }
}

resource "aws_lb_listener_rule" "sample_alb_listener_5503_host_rule" {
  listener_arn = aws_lb_listener.sample_alb_listener_5503.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_alb_tg_5503.arn
  }

  condition {
    host_header {
      values = ["sample.${var.prefix}.game.api.richalien.net"]
    }
  }
}

resource "aws_lb_target_group" "sample_alb_tg_5600" {
  name        = "sample-${var.prefix}-alb-tg-5600"
  port        = 5600
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTPS"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    matcher             = "200-499"
  }

  tags = {
    Name = "sample-${var.prefix}-alb-tg-5600"
  }
}

resource "aws_lb_listener" "sample_alb_listener_5600" {
  load_balancer_arn = aws_lb.sample_alb.arn
  port              = 5600
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_id

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "sample_alb_listener_5600_health_rule" {
  listener_arn = aws_lb_listener.sample_alb_listener_5600.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_alb_tg_5600.arn
  }

  condition {
    source_ip {
      values = [var.cidr_block]
    }
  }
}

resource "aws_lb_listener_rule" "sample_alb_listener_5600_host_rule" {
  listener_arn = aws_lb_listener.sample_alb_listener_5600.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_alb_tg_5600.arn
  }

  condition {
    host_header {
      values = ["sample.backoffice.${var.prefix}.richalien.net"]
    }
  }
}

resource "aws_lb" "sample_nlb" {
  name               = "sample-${var.prefix}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids
  security_groups = [var.nlb_sg_id]

  enable_cross_zone_load_balancing = true
  # enable_cross_zone_load_balancing = false

  tags = {
    Name = "sample-${var.prefix}-nlb"
  }
}

resource "aws_lb_target_group" "sample_nlb_tg_5601" {
  name        = "sample-${var.prefix}-nlb-tg-5601"
  port        = 5601
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
  }

  tags = {
    Name = "sample-${var.prefix}-nlb-tg-5601"
  }
}

resource "aws_lb_target_group" "sample_nlb_tg_5602" {
  name        = "sample-${var.prefix}-nlb-tg-5602"
  port        = 5602
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 30
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
  }

  tags = {
    Name = "sample-${var.prefix}-nlb-tg-5602"
  }
}

resource "aws_lb_listener" "sample_nlb_listener_5601" {
  load_balancer_arn = aws_lb.sample_nlb.arn
  port              = 5601
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_nlb_tg_5601.arn
  }
}

resource "aws_lb_listener" "sample_nlb_listener_5602" {
  load_balancer_arn = aws_lb.sample_nlb.arn
  port              = 5602
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_nlb_tg_5602.arn
  }
}

resource "aws_route53_record" "sample_alb_game_dns" {
  name    = "sample.${var.prefix}.game.api.richalien.net"
  type    = "A"
  zone_id = "Z09427632GW8U1WHN13W1"

  alias {
    evaluate_target_health = true
    name                   = aws_lb.sample_alb.dns_name
    zone_id                = aws_lb.sample_alb.zone_id
  }
}

resource "aws_route53_record" "sample_alb_backoffice_dns" {
  name    = "sample.backoffice.${var.prefix}.richalien.net"
  type    = "A"
  zone_id = "Z09427632GW8U1WHN13W1"

  alias {
    evaluate_target_health = true
    name                   = aws_lb.sample_alb.dns_name
    zone_id                = aws_lb.sample_alb.zone_id
  }
}

resource "aws_route53_record" "sample_nlb_dns" {
  name    = "sample.${var.prefix}.social.api.richalien.net"
  type    = "A"
  zone_id = "Z09427632GW8U1WHN13W1"

  alias {
    evaluate_target_health = true
    name                   = aws_lb.sample_nlb.dns_name
    zone_id                = aws_lb.sample_nlb.zone_id
  }
}

resource "aws_route53_record" "sample_nlb_dns_aaaa" {
  name    = "sample.${var.prefix}.social.api.richalien.net"
  type    = "AAAA"
  zone_id = "Z09427632GW8U1WHN13W1"

  alias {
    evaluate_target_health = true
    name                   = aws_lb.sample_nlb.dns_name
    zone_id                = aws_lb.sample_nlb.zone_id
  }
}