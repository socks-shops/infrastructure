resource "aws_security_group" "eks_sg" {
  name_prefix   = "eks-sg-"
  description   = "EKS security group"
  vpc_id        = var.vpc_id

  ingress {
    description = "Allow traffic from within VPC"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
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
    security_groups = [aws_security_group.eks_sg.id]
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

resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-sg-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.alb_allowed_cidr]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.alb_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_all]
  }

  tags = {
    Name = "alb-sg"
  }
}
