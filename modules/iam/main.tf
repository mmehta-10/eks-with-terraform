resource "aws_iam_instance_profile" "profile" {
  name = "IAM_profile_${var.app_name}"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "IAM_role_${var.app_name}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

output "iam_instance_profile" {
  value = aws_iam_instance_profile.profile.name
}