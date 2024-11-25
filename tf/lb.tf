resource "aws_lb" "this" {
  name               = local.base_name
  load_balancer_type = "application"
  subnets            = values(aws_subnet.public)[*].id
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.self_signed.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2.id
  }
}

resource "aws_lb_target_group" "ec2" {
  name        = local.base_name
  vpc_id      = aws_vpc.this.id
  protocol    = "HTTP"
  port        = 80
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    matcher             = 200
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.ec2.arn
  target_id        = aws_instance.this.id
  port             = 80
}
