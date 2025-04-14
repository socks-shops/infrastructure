# Nom du bucket S3 pour les sauvegardes Velero
variable "velero_bucket_name" {
  default = "mon-bucket-velero-backups" # Remplacez par le nom de votre bucket
}

# Nom du cluster EKS
variable "cluster_name" {
  default = "sockshop-EKS" # Remplacez par le nom de votre cluster EKS
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "oidc_provider" {
  type = string
  description = "ARN de l'OIDC provider EKS"
}

variable "eks_cluster_endpoint" {
  type = string
  description = "Endpoint du cluster EKS"
}

variable "eks_cluster_auth" {
  type = string
  description = "Certificat CA du cluster EKS (base64 encoded)"
}

variable "eks_token" {
  type = string
  description = "Token d'authentification pour le cluster EKS"
}