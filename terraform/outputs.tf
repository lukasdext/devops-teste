# Output do endereço IP público
output "public_ip" {
  value = aws_instance.my_instance.public_ip
}