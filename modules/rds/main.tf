resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "MySQL Subnet Group"
  }
}

data "aws_ssm_parameter" "rds_db_name" {
  name = "rds-db_name"
}

data "aws_ssm_parameter" "rds_db_username" {
  name = "rds-db_username"
}

data "aws_ssm_parameter" "rds_db_password" {
  name = "rds-db_password"
}


resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = data.aws_ssm_parameter.rds_db_name.value
  username             = data.aws_ssm_parameter.rds_db_username.value
  password             = data.aws_ssm_parameter.rds_db_password.value
  skip_final_snapshot  = true
  vpc_security_group_ids = [var.rds_sg_id]  # Associe le groupe de sécurité RDS

  multi_az             = false
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.mysql_subnet_group.name

  backup_retention_period = var.backup_retention_period

  tags = {
    Name = "mysql-instance"
  }
}
