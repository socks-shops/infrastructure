#!/bin/bash
set -e

# Vérifie que les variables d’environnement sont définies
if [ -z "$DOCDB_USERNAME" ] || [ -z "$DOCDB_PASSWORD" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
  echo "Erreur : DOCDB_USERNAME, DOCDB_PASSWORD, DB_NAME, DB_USERNAME et DB_PASSWORD doivent être définis en tant que variables d’environnement."
  exit 1
fi

AWS_REGION="eu-west-3"

# Ajout des paramètres dans le Parameter Store pour DocumentDB
aws ssm put-parameter --name "/docdb/username" --value "$DOCDB_USERNAME" --type "SecureString" --overwrite --region "$AWS_REGION"
aws ssm put-parameter --name "/docdb/password" --value "$DOCDB_PASSWORD" --type "SecureString" --overwrite --region "$AWS_REGION"

# Ajout des nouveaux paramètres pour RDS
aws ssm put-parameter --name "/rds/db_name" --value "$DB_NAME" --type "String" --overwrite --region "$AWS_REGION"
aws ssm put-parameter --name "/rds/db_username" --value "$DB_USERNAME" --type "String" --overwrite --region "$AWS_REGION"
aws ssm put-parameter --name "/rds/db_password" --value "$DB_PASSWORD" --type "SecureString" --overwrite --region "$AWS_REGION"

echo "✅ Paramètres ajoutés avec succès."
