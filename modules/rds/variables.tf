variable "vpc_id" {
  description = "The ID of the VPC where RDS will be deployed."
  type        = string
}

variable "rds_sg_id" {
  description = "The security group ID for RDS MySQL."
  type        = string
}

variable "private_subnet_ids" {
  description = "The list of private subnet IDs where the RDS instance will be placed."
  type        = list(string)
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

