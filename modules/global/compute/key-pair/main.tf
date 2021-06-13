# Generates a key pair that can be used by multiple instances
provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.vpc_region
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name #
  public_key = file("${path.module}/${var.filepath}")
}
