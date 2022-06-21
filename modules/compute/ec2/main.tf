# userdata for the server ...
data "template_file" "userdata" {
  template = var.user_data_script #file("${path.module}/scripts/jenkins_server.sh")

}

# Place server in any one of the given subnets, selected
# at random.
resource "random_shuffle" "subnets" {
  input        = var.public_subnet_ids
  result_count = 1
}

# create the ec2 instance
resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = "t2.medium"

  subnet_id              = random_shuffle.subnets.result[0]
  vpc_security_group_ids = [var.security_group_ids]
  iam_instance_profile   = var.iam_instance_profile
  user_data              = data.template_file.userdata.rendered
  # key_name = aws_key_pair.jenkins_server.key_name
  key_name = var.key_name

  tags = {
    Name = var.instance_name
  }

  root_block_device {
    delete_on_termination = true
  }
}

