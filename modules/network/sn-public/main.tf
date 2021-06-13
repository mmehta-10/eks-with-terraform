# Query all avilable Availibility Zone
data "aws_availability_zones" "available" {}

## Public subnet
# TODO: https://github.com/100daysofdevops/21_days_of_aws_using_terraform/blob/master/vpc/main.tf
/* resource "aws_subnet" "public" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr
  availability_zone = var.subnet_az

  tags = {
    Name = "public_${var.subnet_name}"
  }
} */

# Subnet (public)
# https://github.com/maneet8/subnetperazterraform/blob/master/vpc.tf
resource "aws_subnet" "public_subnet" {
  count                   = var.az_count
  availability_zone       = element(split(", ", var.availability_zones), count.index)
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.${10 + count.index}.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

## Internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = "PublicSubnet"
  }
}

## Routing table
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_route" "gateway_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

## Associate the routing table to public subnet
resource "aws_route_table_association" "rt_assn" {
  count     = var.az_count
  subnet_id = element(aws_subnet.public_subnet.*.id, count.index)
  # subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
