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
  cluster_name       = "eks_cluster_using_terraform"
}

# module "private_subnets" {
#   source = "./modules/network/sn-private"

#   az_count           = var.az_count
#   availability_zones = var.availability_zones
#   vpc_id             = module.vpc.id
#   cluster_name       = "eks_cluster_using_terraform"
# }

terraform {
  backend "s3" {
    bucket  = "s3-new-terraform-state-123"
    encrypt = true
    key     = "terraform.tfstate"
    region  = "us-east-1"
    profile = "assignments"
  }
}

# ###############################################################################
# # Kubernetes
# ###############################################################################

module "eks" {
  source     = "./modules/compute/eks"
  region     = var.vpc_region
  subnet_ids = module.public_subnets.public_subnet_ids
  # subnet_ids = module.private_subnets.private_subnet_ids
}

###############################################################################
# Ingress
###############################################################################

module "ingress" {
  source       = "./modules/network/ingress"
  cluster_name = module.eks.cluster_name
}

module "lambda" {
  source       = "./modules/compute/lambda"
  function_name = "lambda_authorizer"
}