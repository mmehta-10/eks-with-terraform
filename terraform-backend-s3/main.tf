variable "vpc_region" {
  description = "AWS region"
  default     = "us-east-1"
}

provider "aws" {
  region                  = var.vpc_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

## Configure backend
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-backend-in-s3-for-eks-with-terraform"

  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block_terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# terraform {
#   backend "s3" {
#     bucket  = "terraform-backend-in-s3-for-eks-with-terraform"
#     key     = "terraform.tfstate"
#     region  = "us-east-1"
#     encrypt = true
#   }
# }