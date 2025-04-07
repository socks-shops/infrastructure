variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_account_id" {
  default = "AIDAYHJANKMVIQU7X5WBQ"
}

variable "iam_role_name" {
  default = "iam_role_sockshop"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "worker_node_instance_type" {
  default = ["m5.xlarge"]
}

variable "eks_version" {
  default = "1.29"
}

variable "docdb_instance_class" {
  default = "db.t3.medium"
}

variable "eks_key_pair" {
  description = "Nom de la clé SSH"
  default     = "sockshop-keypair" # Le nom de la clé SSH
}

variable "nbr_instance_docdb" {
  default = 1
}

variable "docdb_cluster_id" {
  default = "sockshop-docdb-cluster"
}

variable "backup_docdb_period" {
  default = 1
}

variable "backup_rds_period" {
  default = 1
}

variable "backup_time_window" {
  default = "07:00-09:00"
}

variable "desired_worker_node" {
  default = 1
}

variable "max_worker_node" {
  default = 5
}

variable "min_worker_node" {
  default = 1
}

variable "subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "cidr_all" {
  default = "0.0.0.0/0"
}

variable "availability_zone_1" {
  default = "us-east-1a"
}

variable "availability_zone_2" {
  default = "us-east-1b"
}


#**************** ALB Variables **************************
variable "alb_name" {
  description = "Nom du Load Balancer"
  default     = "socks-shop-lb"
}


variable "target_group_name" {
  description = "Nom du Target Group"
  default     = "socks-shop-frontend"
}

variable "target_group_port" {
  description = "Port du Target Group"
  default     = 8080 # à remplacer 
}

variable "certificate_arn" {
  description = "ARN du certificat SSL pour HTTPS"
  type        = string
  default     = "value"
}


#route 53 
variable "domain_name" {
  description = "Nom de domaine"
  default     = "datascientets-socks-shop.com"
}

variable "subdomain_name" {
  description = "Sous-domaine à créer"
  type        = string
  default     = "www.datascientets-socks-shop.com"
}
