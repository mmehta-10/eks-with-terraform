variable "key_name" {
  default = "devops-lab"
}

variable "filepath" {
  default = "devops-lab.pub"
}

# main creds for AWS connection
variable "aws_access_key_id" {
  description = "AWS access key"
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  default     = ""
}

variable "vpc_region" {
  description = "AWS region"
  default     = "us-east-1"
}