provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "sockshop-tfstate-datascientest"
    key    = "sockshop.tfstate"
    region = "us-east-1"
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


module "alb" {
  source             = "./modules/alb"
  alb_name           = var.alb_name
  alb_security_group = module.securitygroup.alb_sg_id
  public_subnets     = module.network.public_subnet_ids
  vpc_id             = module.network.vpc_id
  target_group_name  = var.target_group_name
  target_group_port  = var.target_group_port
  certificate_arn    = var.certificate_arn
}


module "route53" {
  source         = "./modules/route53"
  domain_name    = var.domain_name
  subdomain_name = var.subdomain_name
  alb_dns_name   = module.alb.alb_dns_name
  alb_zone_id    = module.alb.alb_zone_id
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

output "OIDC" {
  value = module.eks.oidc_provider_arn
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_z_id" {
  value = module.alb.alb_zone_id
}

