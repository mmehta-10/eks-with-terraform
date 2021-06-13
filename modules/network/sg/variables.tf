variable "vpc_id" {}
variable "vpc_region" {}
variable "app_name" {}
variable "subnet_public_cidr" {}
variable "ingress_rules" {}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound open"
    }
  ]
}
