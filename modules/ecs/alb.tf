resource "aws_lb" "this" {
  name               = "sessionize-dev"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "http" {
  name        = "sessionize-dev"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}

data "aws_acm_certificate" "issued" {
  domain   = "sessionize-test-slackbot.codurance.io"
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

data "aws_route53_zone" "this" {
  name         = "codurance.io."
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.this.id
  name    = "sessionize-test-slackbot.codurance.io"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.this.dns_name]
}
