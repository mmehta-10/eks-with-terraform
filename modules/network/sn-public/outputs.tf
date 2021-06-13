output "id" {
  value = aws_subnet.public_subnet.*.id
}

output "az" {
  # value = var.subnet_az
  value = aws_subnet.public_subnet.*.availability_zone
}

/* output "key_name" {
  value = aws_key_pair.key_pair.key_name
}

output "public_key" {
  value = aws_key_pair.key_pair.public_key
}

output "private_key" {
  value     = tls_private_key.private_key.private_key_pem
  sensitive = true
} */

# Added on Jan 13
# https://github.com/100daysofdevops/21_days_of_aws_using_terraform/blob/master/vpc/outputs.tf
output "public_subnet_ids" {
  value = aws_subnet.public_subnet.*.id
}

output "public_subnet_cidrs" {
  value = aws_subnet.public_subnet.*.cidr_block
}

