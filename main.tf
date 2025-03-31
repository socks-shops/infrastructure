provider "aws" {
  region = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket = "sockshop-tfstate-mahdi"
    key    = "sockshop.tfstate"
    region = "eu-west-3"
  }
}

# Définir les variables locales, y compris le nom et le chemin de la clé
locals {
  key_name = "sockshop-keypair"                # Nom de la clé SSH à créer
  key_path = "./keypair/${local.key_name}.pem" # Chemin pour sauvegarder la clé privée
}

module "network" {
  source               = "./modules/network"
  network_name         = "sock-shop-network"
  vpc_cidr             = var.vpc_cidr
  az1_pub_subnet_cidr  = "10.0.1.0/24" #var.subnet_cidr
  az2_pub_subnet_cidr  = "10.0.2.0/24" #var.subnet_cidr
  az1_priv_subnet_cidr = "10.0.3.0/24" #var.subnet_cidr
  az2_priv_subnet_cidr = "10.0.4.0/24" #var.subnet_cidr
  cidr_all             = var.cidr_all
  public_az1           = var.availability_zone_1
  public_az2           = var.availability_zone_2
  private_az1          = var.availability_zone_1
  private_az2          = var.availability_zone_2
}


module "eks" {
  source                        = "./modules/eks"
  subnet_ids                    = module.network.private_subnet_ids
  cluster_name                  = "sockshop-EKS"
  eks_node_group_name           = "node_group_sockshop"
  iam_role_name                 = "iam_role_sockshop"
  eks_key_pair                  = local.key_name
  vpc_id                        = module.network.vpc_id
  vpc_cidr                      = var.vpc_cidr
  cidr_all                      = var.cidr_all
  eks_desired_worker_node       = var.desired_worker_node
  eks_min_worker_node           = var.min_worker_node
  eks_max_worker_node           = var.max_worker_node
  eks_worker_node_instance_type = var.worker_node_instance_type
  eks_version                   = var.eks_version
  aws_region                    = var.region
  account_id                    = var.aws_account_id
  eks_sg                        = module.securitygroup.eks_sg_id
}



module "documentdb" {
  source                  = "./modules/documentdb"
  vpc_id                  = module.network.vpc_id
  vpc_cidr                = var.vpc_cidr
  private_subnet_ids      = module.network.private_subnet_ids
  cluster_identifier      = var.docdb_cluster_id
  backup_retention_period = var.backup_docdb_period
  preferred_backup_window = var.backup_time_window
  instance_class          = var.docdb_instance_class
  instance_count          = var.nbr_instance_docdb
  docdb_sg                = [module.securitygroup.docdb_sg_id]
}

module "rds" {
  source                  = "./modules/rds"
  vpc_id                  = module.network.vpc_id
  rds_sg_id               = module.securitygroup.rds_sg_id
  private_subnet_ids      = module.network.private_subnet_ids
  backup_retention_period = var.backup_rds_period
}

module "securitygroup" {
  source   = "./modules/securitygroup"
  vpc_id   = module.network.vpc_id
  vpc_cidr = var.vpc_cidr
  cidr_all = var.cidr_all
}


# Module KeyPair
module "keypair" {
  source          = "./modules/keypair"
  ds_key_filename = local.key_path
  eks_key_pair    = local.key_name # Passe la variable correcte pour la clé SSH
}


output "vpc_id" {
  value = module.network.vpc_id
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
