resource "aws_security_group" "eks_sg" {
  name_prefix   = "eks-sg-"
  description   = "EKS security group"
  vpc_id        = var.vpc_id

  ingress {
    description = "Allow traffic from within VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_all]
  }

  tags = {
    Name = "eks-sg"
  }
}

resource "aws_security_group" "docdb_sg" {
  name_prefix   = "docdb-sg-"
  description   = "DocumentDB security group"
  vpc_id        = var.vpc_id

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
    Name = "docdb-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix   = "rds-sg-"
  description   = "RDS MySQL security group"
  vpc_id        = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "rds-sg"
  }
}
