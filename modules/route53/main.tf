resource "aws_route53_zone" "sockshop_zone" {
  name = "datascientets-socks-shop.com."
}

resource "aws_route53_record" "alb_record" {
  zone_id = aws_route53_zone.sockshop_zone.id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name  # L'ALB doit être déjà défini dans ton module ALB
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "www_record" {
  zone_id = aws_route53_zone.sockshop_zone.id
  name    = var.subdomain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name   #  aws_lb.alb.dns_name  # L'ALB doit être déjà défini dans ton module ALB
    zone_id                = var.alb_zone_id   #aws_lb.alb.zone_id
    evaluate_target_health = true
  }

}
