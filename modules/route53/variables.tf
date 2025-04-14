variable "domain_name" {
  description = "Nom de domaine principal (ex: example.com)"
  type        = string
  default = "datascientets-socks-shop.com"
}

variable "subdomain_name" {
  description = "Sous-domaine à créer (ex: app.example.com)"
  type        = string
  default = "www.datascientets-socks-shop.com"
}

variable "alb_dns_name" {
  description = "Nom DNS de l'ALB (récupéré après la création de l'ALB)"
  type        = string
  default = "dns_name"
}

variable "alb_zone_id" {
  description = "Zone ID de l'ALB (fourni par AWS)"
  type        = string
}
