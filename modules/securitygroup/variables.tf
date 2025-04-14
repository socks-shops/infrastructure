variable "vpc_id" {
  description = "The ID of the VPC where the security groups will be created."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC (for ingress rules)."
  type        = string
}

variable "cidr_all" {
  description = "CIDR block for all outbound traffic (egress)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "alb_allowed_cidr" {
  description = "CIDR block allowed to access the ALB (Default: open to all)"
  type        = string
  default     = "0.0.0.0/0"
}