output "public_ip" {
  value = aws_eip.eip.public_ip
}

output "id" {
  value = aws_instance.nat.id
}

output "key_name" {
  value = aws_key_pair.key_pair.key_name
}

output "private_key" {
  sensitive = true
  value     = tls_private_key.private_key.private_key_pem
}
