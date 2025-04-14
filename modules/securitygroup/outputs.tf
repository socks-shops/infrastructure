output "eks_sg_id" {
  description = "The ID of the EKS security group"
  value       = aws_security_group.eks_sg.id
}

output "docdb_sg_id" {
  description = "The ID of the DocumentDB security group"
  value       = aws_security_group.docdb_sg.id
}

output "rds_sg_id" {
  description = "The ID of the RDS MySQL security group"
  value       = aws_security_group.rds_sg.id
}

# output "alb_sg_id" {
#   description = "The ID of the ALB security group"
#   value       = aws_security_group.sg_alb.id
# }