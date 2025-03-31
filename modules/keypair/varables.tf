# variables.tf du module keypair

variable "eks_key_pair" {
  description = "Nom de la clé SSH à créer"
  type        = string
}

variable "ds_key_filename" {
  description = "Chemin où la clé privée sera enregistrée localement"
  type        = string
}
