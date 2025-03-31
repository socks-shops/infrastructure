/*resource "aws_security_group" "docdb_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docdb_sg"
  }
}*/

data "aws_ssm_parameter" "docdb_username" {
  name = "docdb-username"
}

data "aws_ssm_parameter" "docdb_password" {
  name = "docdb-password"
}

resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "docdb-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "docdb-subnet-group"
  }
}

resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier      = var.cluster_identifier
  engine                  = "docdb"
  master_username         = data.aws_ssm_parameter.docdb_username.value
  master_password         = data.aws_ssm_parameter.docdb_password.value
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  db_subnet_group_name    = aws_docdb_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids  = var.docdb_sg #[aws_security_group.docdb_sg.id]

  # Ignorer le snapshot final lors de la destruction
  skip_final_snapshot     = true

  # S'assurer qu'il n'y a pas de snapshot final
  #final_snapshot_identifier = ""  # Force la suppression sans snapshot final
}



resource "aws_docdb_cluster_instance" "docdb_instance" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-${count.index}"
  cluster_identifier = aws_docdb_cluster.docdb_cluster.id
  instance_class     = var.instance_class
}
