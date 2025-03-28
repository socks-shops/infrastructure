output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "public subnet IDs"
  value       = [aws_subnet.pub_subnet_az1.id, aws_subnet.pub_subnet_az2.id]
}


output "private_subnet_ids" {
  description = "private subnet IDs"
  value       = [aws_subnet.priv_subnet_az1.id, aws_subnet.priv_subnet_az2.id]
}
