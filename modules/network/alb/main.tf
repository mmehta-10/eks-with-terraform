resource "aws_lb_target_group" "aws_lb_target_group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group_attachment" "aws_lb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.aws_lb_target_group.arn
  target_id        = var.target_id
  port             = var.target_group_port
}

resource "aws_lb" "aws_lb" {
  name     = var.alb_name
  internal = false

  # security_groups = [
  #   aws_security_group.aws_security_group.id,
  # ]

  security_groups = [var.security_group_id]

  subnets = var.public_subnet_ids

  tags = {
    Name = "my-test-alb"
  }

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "aws_lb_listener" {
  load_balancer_arn = aws_lb.aws_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws_lb_target_group.arn
  }
}

