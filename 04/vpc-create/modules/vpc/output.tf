output "myvpc_id" {
  value       = aws_vpc.myvpc.id
  description = "vpc ID"
}
output "subnet_id" {
  value = aws_subnet.mysubnet.id
  description = "Subnet ID "
}
