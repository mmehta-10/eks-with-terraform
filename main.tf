###############################################################################
# Provider
###############################################################################
provider "aws" {
  # access_key = var.aws_access_key_id
  # secret_key = var.aws_secret_access_key
  region                  = var.vpc_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

###############################################################################
# Base Network
###############################################################################

module "vpc" {
  source = "./modules/network/vpc"

  vpc_region     = var.vpc_region
  vpc_name       = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block
}

module "public_subnets" {
  source = "./modules/network/sn-public"

  az_count           = var.az_count
  availability_zones = var.availability_zones
  vpc_id             = module.vpc.id
}

terraform {
  backend "s3" {
    bucket  = "terraform-backend-in-s3-for-eks-with-terraform"
    encrypt = true
    key     = "terraform.tfstate"
    region  = "us-east-1"
  }
}

# Create EC2 key pair with defaults
# module "aws_key_pair" {
#   source = "./modules/global/compute/key-pair"
# }

###############################################################################
# Kubernetes
###############################################################################

# Create EC2 key pair with defaults
module "eks" {
  source     = "./modules/compute/eks"
  depends_on = [module.public_subnets]
}

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  # token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file = true
  # version                = "~> 1.11"
}