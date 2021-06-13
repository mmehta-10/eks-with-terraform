# ###############################################################################
# # ALL OUTBOUND
# ###############################################################################

# resource "aws_security_group_rule" "jenkins_server_to_other_machines_ssh" {
#   type              = "egress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   security_group_id = aws_security_group.security_group.id
#   cidr_blocks       = ["0.0.0.0/0"]
#   description       = "allow jenkins servers to ssh to other machines"
# }

# resource "aws_security_group_rule" "jenkins_server_outbound_all_80" {
#   type              = "egress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   security_group_id = aws_security_group.security_group.id
#   cidr_blocks       = ["0.0.0.0/0"]
#   description       = "allow jenkins servers for outbound yum"
# }
