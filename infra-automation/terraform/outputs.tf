output "public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "The public IP of the EC2 instance."
}