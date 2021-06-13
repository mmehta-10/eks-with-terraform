# Expected variables from the caller
variable "vpc_id" {}

variable "ami_id_nat" {}
variable "instance_type_nat" {}

variable "subnet_public" {}
variable "subnet_public_id" {}
variable "subnet_public_az" {}
variable "subnet_public_private_key" {}

variable "subnet_private_cidr_ranges" {
  type = list(string)
}

variable "subnet_private_01" {}
variable "subnet_private_01_rt_id" {}
variable "subnet_private_01_private_key" {}

variable "subnet_private_02" {}
variable "subnet_private_02_rt_id" {}
variable "subnet_private_02_private_key" {}
