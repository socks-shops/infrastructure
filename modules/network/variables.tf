variable "network_name" {
  default     = "sock-shop-network"
  description = "sock-shop-network"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR range of the VPC"
}

variable "az1_pub_subnet_cidr" {
  default     = "10.0.0.0/24"
  type        = string
  description = "CIDR range of public subnet in the first availability zone "
}

variable "az2_pub_subnet_cidr" {
  default     = "10.0.0.0/24"
  type        = string
  description = "CIDR range of public subnet in the second availability zone "
}

variable "az1_priv_subnet_cidr" {
  default     = "10.0.1.0/24"
  type        = string
  description = "CIDR range of private subnet in the first availability zone "
}

variable "az2_priv_subnet_cidr" {
  default     = "10.0.2.0/24"
  type        = string
  description = "CIDR range of private subnet in the second availability zone "
}

variable "cidr_all" {
  default     = "0.0.0.0/0"
  type        = string
  description = "if needed this variable give acess for all "
}

variable "public_az1" {
  default     = "us-east-1a"
  type        = string
  description = "availability zone for the first public subnet "
}

variable "public_az2" {
  default     = "us-east-1a"
  type        = string
  description = "availability zone for the second public subnet "
}

variable "private_az1" {
  default     = "us-east-1a"
  type        = string
  description = "availability zone for the first private subnet "
}

variable "private_az2" {
  default     = "us-east-1b"
  type        = string
  description = "availability zone for the second private subnet "
}



