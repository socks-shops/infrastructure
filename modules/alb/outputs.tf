output "alb_arn" {
  description = "ARN du Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "Nom DNS du Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "target_group_arn" {
  description = "ARN du Target Group"
  value       = aws_lb_target_group.alb_target_group.arn
}

output "alb_zone_id" {
  description = "ID de la zone DNS du Load Balancer"
  value       = aws_lb.alb.zone_id
}

