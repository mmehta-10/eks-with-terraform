variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "security_group_ids" {}
variable "iam_instance_profile" {}
variable "user_data_script" {}

variable "ami_id" {
  description = "AMI used for EC2"
  default     = "ami-030e9a3020e6272f7"
}

variable "instance_name" {
  description = "AMI used for EC2"
  default     = "created_by_terraform"
}

variable "key_name" {}