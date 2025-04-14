output "route53_zone_id" {
  description = "L'ID de la zone Route 53"
  value       = aws_route53_zone.main.zone_id
}

output "route53_record_fqdn" {
  description = "L'adresse complète du sous-domaine"
  value       = aws_route53_record.alb_record.fqdn
}
