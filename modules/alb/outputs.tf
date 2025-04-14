output "alb_arn" {
  description = "ARN du Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "Nom DNS du Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "ID de la zone DNS du Load Balancer"
  value       = aws_lb.alb.zone_id
}

