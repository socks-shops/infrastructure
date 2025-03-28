variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_name" {
  default     = "sockshop-EKS"
  description = "sockshop-EKS"
}

variable "eks_node_group_name" {
  default     = "eks_node_group_name"
  description = "sockshop_eks_node_group_name"
}

variable "iam_role_name" {
  default     = "eks_iam_role_name"
  description = "eks_node_group_name"
}

variable "eks_key_pair" {
  default     = "eks_key_pair"
  description = "eks_key_pair"
}

variable "vpc_id" {
  default     = "vpc_id"
  description = "vpc_id"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "10.0.0.0/16"
}

variable "cidr_all" {
  default     = "0.0.0.0/0"
  description = "0.0.0.0/0"
}

variable "eks_desired_worker_node" {
  default     = 2
  description = "eks_desired_worker_node"
}

variable "eks_min_worker_node" {
  default = 2
  description = "eks_min_worker_node"
}

variable "eks_max_worker_node" {
  default = 4
  description = "eks_max_worker_node"
}

variable "eks_worker_node_instance_type" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "t3.medium"
}

variable "eks_version" {
  default = "1.29"
  description = "1.29"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "eks_sg" {
  description = "security groupe of EKS"
}