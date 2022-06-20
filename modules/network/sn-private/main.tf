resource "aws_subnet" "private_subnet" {
  count                   = var.az_count
  availability_zone       = element(split(", ", var.availability_zones), count.index)
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  # map_public_ip_on_launch = true

  tags = {
    Name                                        = "PrivateSubnet",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
    "kubernetes.io/role/intenal-elb"                    = "1"
  }
}

# Routing table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "PrivateSubnet"
  }
}

# Associate the routing table to private subnet
resource "aws_route_table_association" "rt_assn" {
  # subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id

  count     = var.az_count
  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
}

# ## Create a private key that'll be used for access to Bastion host
# resource "tls_private_key" "private_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "key_pair" {
#   key_name   = "private_${var.subnet_name}"
#   public_key = tls_private_key.private_key.public_key_openssh
# }
