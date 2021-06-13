# NAT Gateway security group
# Since we'll also use NAT Gateway as a bastion host to get into private subnet,
# it needs block all unnecessary traffic. This should only allow
# - ingress SSH from internet
# - ingress from private subnets
# - egress to internet for any traffic
resource "aws_security_group" "nat_sg" {
  name   = "nat_sg_${var.subnet_public}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.subnet_private_cidr_ranges
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    from_port = -1
    to_port   = -1
    protocol  = "icmp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "sg_nat_${var.subnet_public}"
  }
}

## Create a private key that'll be used for access to Bastion host/NAT Gateway
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "bastion_${var.subnet_public}"
  public_key = tls_private_key.private_key.public_key_openssh
}

## Write the private key to access bastion host in a file
resource "local_file" "bastion_private_key_local" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "${path.module}/id_rsa_bastion.pem"
}

## Write the private key to access public instances in a file
resource "local_file" "subnet_public_private_key_local" {
  content  = var.subnet_public_private_key
  filename = "${path.module}/id_rsa_${var.subnet_public}.pem"
}

## Write the private key to access private instances in a file
resource "local_file" "subnet_private_01_private_key_local" {
  content  = var.subnet_private_01_private_key
  filename = "${path.module}/id_rsa_${var.subnet_private_01}.pem"
}

## Write the private key to access private instances in a file
resource "local_file" "subnet_private_02_private_key_local" {
  content  = var.subnet_private_02_private_key
  filename = "${path.module}/id_rsa_${var.subnet_private_02}.pem"
}

## NAT Gateway.
## This will be needed by any private subnet(s) to connect to Internet
resource "aws_instance" "nat" {
  ami               = var.ami_id_nat
  availability_zone = var.subnet_public_az
  subnet_id         = var.subnet_public_id
  instance_type     = var.instance_type_nat
  key_name          = aws_key_pair.key_pair.key_name

  vpc_security_group_ids = [
    "${aws_security_group.nat_sg.id}",
  ]

  associate_public_ip_address = true
  source_dest_check           = false

  ## update the permissions of private key file needed to access bastion
  provisioner "local-exec" {
    command = "chmod -c 600 ${path.module}/id_rsa_bastion.pem"
  }

  ## Add the private key to access public instances in .ssh folder
  provisioner "file" {
    source      = "${path.module}/id_rsa_${var.subnet_public}.pem"
    destination = "/home/ec2-user/.ssh/id_rsa_${var.subnet_public}.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.private_key.private_key_pem
    }
  }

  ## Add the private key to access private instances in .ssh folder
  provisioner "file" {
    source      = "${path.module}/id_rsa_${var.subnet_private_01}.pem"
    destination = "/home/ec2-user/.ssh/id_rsa_${var.subnet_private_01}.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.private_key.private_key_pem
    }
  }

  ## Add the private key to access private instances in .ssh folder
  provisioner "file" {
    source      = "${path.module}/id_rsa_${var.subnet_private_02}.pem"
    destination = "/home/ec2-user/.ssh/id_rsa_${var.subnet_private_02}.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.private_key.private_key_pem
    }
  }

  ## Update permissions on all the keys
  provisioner "remote-exec" {
    inline = [
      "chmod -c 600 /home/ec2-user/.ssh/id_rsa_${var.subnet_public}.pem",
      "chmod -c 600 /home/ec2-user/.ssh/id_rsa_${var.subnet_private_01}.pem",
      "chmod -c 600 /home/ec2-user/.ssh/id_rsa_${var.subnet_private_02}.pem",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.private_key.private_key_pem
    }
  }

  ## Since the private key has been added to bastion host, remove it from local
  provisioner "local-exec" {
    command = "rm -f ${path.module}/id_rsa_${var.subnet_public}.pem"
  }

  provisioner "local-exec" {
    command = "rm -f ${path.module}/id_rsa_${var.subnet_private_01}.pem"
  }

  provisioner "local-exec" {
    command = "rm -f ${path.module}/id_rsa_${var.subnet_private_02}.pem"
  }

  tags = {
    Name = "nat_${var.subnet_public}"
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.nat.id
  vpc      = true
}

## Route the internet bound traffic for both public subnets via NAT instance
resource "aws_route" "subnet_private_01_route" {
  route_table_id         = var.subnet_private_01_rt_id
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = aws_instance.nat.id
}

resource "aws_route" "subnet_private_02_route" {
  route_table_id         = var.subnet_private_02_rt_id
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = aws_instance.nat.id
}
