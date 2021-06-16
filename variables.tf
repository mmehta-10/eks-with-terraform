# main creds for AWS connection
variable "vpc_region" {
  description = "AWS region"
  default     = "us-east-1"
}

# VPC Config
variable "vpc_name" {
  description = "VPC for EKS with terraform"
  default     = "vpc-for-eks-terraform"
}

variable "vpc_cidr_block" {
  description = "IP addressing for demo Network"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "number of active availability zones in VPC"
  default     = "2"
}

variable "availability_zones" {
  description = "comma separated string of availability zones in order of precedence"
  default     = "us-east-1a, us-east-1d, us-east-1e, us-east-1c"
}