output "EC2_public_ip" {
    value = aws_instance.dev-server.public_ip
    description = "EC2 pb ip address"
}