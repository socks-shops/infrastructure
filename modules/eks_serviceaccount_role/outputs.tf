output "kms_key_arn" {
  value       = aws_kms_key.velero_operators_key.arn
  description = "ARN de la clé KMS utilisée pour le chiffrement des sauvegardes et des données des opérateurs."
}