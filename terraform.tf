# terraform {
#   backend "s3" {
#     bucket  = "terraform-backend-in-s3-for-eks-with-terraform"
#     encrypt = true
#     key     = "terraform.tfstate"
#     region  = "us-east-1"
#   }
# }