output "alb_dns_name" {
  value = aws_lb.aws_lb.dns_name
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.aws_lb_target_group.arn
}