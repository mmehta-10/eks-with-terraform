locals {
  bucket_name = "s3-new-terraform-state-123"
}

provider "aws" {
  region                  = var.vpc_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                 = var.aws_profile
}

## Create bucket for storing TF state in S3 backend 
module "backend" {
  source        = "../modules/s3"

  vpc_region  = var.vpc_region
  bucket_name = local.bucket_name
}