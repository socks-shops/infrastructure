# main.tf du module keypair

# Créer la clé privée et publique
resource "tls_private_key" "eks_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Créer la paire de clés AWS
resource "aws_key_pair" "eks_key" {
  key_name   = var.eks_key_pair  # Le nom de la clé SSH que nous passons en variable
  public_key = tls_private_key.eks_private_key.public_key_openssh
}

# Sauvegarder la clé privée dans un fichier local
resource "local_file" "eks_file" {
  filename        = var.ds_key_filename  # Le chemin où la clé privée sera enregistrée
  content         = tls_private_key.eks_private_key.private_key_pem
  file_permission = "0400"  # Permissions strictes sur la clé privée
}
