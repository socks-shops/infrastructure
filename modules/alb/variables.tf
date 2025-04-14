variable "alb_name" {
  description = "Nom du Load Balancer"
  type        = string
}

variable "alb_security_group" {
  description = "ID du Security Group du Load Balancer"
  type        = string
}

variable "public_subnets" {
  description = "Liste des subnets publics où déployer l'ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "target_group_name" {
  description = "Nom du Target Group"
  type        = string
}

variable "target_group_port" {
  description = "Port du Target Group"
  type        = number
}

variable "certificate_arn" {
  description = "ARN du certificat SSL pour HTTPS"
  type        = string
}
