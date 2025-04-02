variable "region" {
  description = "AWS Region"
  default     = "eu-west-3"
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
  default = "eu-west-3a"
}

variable "availability_zone_2" {
  default = "eu-west-3b"
}

