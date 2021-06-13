resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr
  availability_zone = var.subnet_az

  tags = {
    Name = "private_${var.subnet_name}"
  }
}

# Routing table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "private_${var.subnet_name}"
  }
}

# Associate the routing table to private subnet
resource "aws_route_table_association" "rt_assn" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id
}

## Create a private key that'll be used for access to Bastion host
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "private_${var.subnet_name}"
  public_key = tls_private_key.private_key.public_key_openssh
}
