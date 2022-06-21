provider "aws" {
  region                  = var.vpc_region
  shared_credentials_files = ["~/.aws/credentials"]
  profile                 = var.aws_profile

  default_tags {
    tags = {
      environment     = "dev"
      aws-service         = "eks"
      creator = "Megha Mehta"
      assignment = "101digital"
    }
  }  
}
