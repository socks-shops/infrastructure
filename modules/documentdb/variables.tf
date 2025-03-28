variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for Security Group"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "cluster_identifier" {
  description = "Cluster identifier"
  type        = string
  default     = "my-docdb-cluster"
}


variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "07:00-09:00"
}

variable "instance_class" {
  description = "Instance class for DocumentDB"
  type        = string
  default     = "db.t3.medium"
}

variable "instance_count" {
  description = "Number of DocumentDB instances"
  type        = number
  default     = 1
}

variable "docdb_sg" {
  description = "security groupe of documentdb"
  type        = list(string)
}