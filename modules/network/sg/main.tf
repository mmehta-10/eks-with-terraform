# Security Group:
resource "aws_security_group" "security_group" {
  name        = "security_group_for_${var.app_name}"
  description = "Created by Terraform"

  # legacy name of VPC ID
  vpc_id = var.vpc_id

  tags = {
    Name = var.app_name
  }
}

resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_rules)

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_blocks
  description       = var.ingress_rules[count.index].description
  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "egress_rules" {
  count = length(var.egress_rules)

  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = var.egress_rules[count.index].cidr_blocks
  description       = var.egress_rules[count.index].description
  security_group_id = aws_security_group.security_group.id
}

output "security_group_id" {
  value = aws_security_group.security_group.id
}
