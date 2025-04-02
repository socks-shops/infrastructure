
resource "aws_iam_role" "master" {
  name = "${var.iam_role_name}-master"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.master.name
}




# Rôle IAM administrateur complet
resource "aws_iam_role" "full_admin" {
  name = "full_admin_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${var.account_id}:root"  # Utilise ton propre ARN de compte ici
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attacher la politique d'administration complète (AdministratorAccess) à ce rôle
resource "aws_iam_role_policy_attachment" "full_admin_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.full_admin.name
}


resource "aws_iam_role" "worker" {
  name = "${var.iam_role_name}-worker"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

#*****************************************************************#
# Création de la politique IAM pour accéder aux paramètres SSM
/*resource "aws_iam_policy" "docdb_ssm_policy" {
  name        = "DocDBParameterPolicy"
  description = "Policy to manage DocumentDB credentials in SSM Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DescribeParameters"
        ],
        Resource = "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/docdb/*"
      }
    ]
  })
}
*/

resource "aws_iam_policy" "docdb_ssm_policy" {
  name        = "DocDBParameterPolicy"
  description = "Policy to manage DocumentDB credentials in SSM Parameter Store"
  policy = file("${path.module}/docdb_ssm_policy.json")
}


# Attachement de la politique IAM au rôle master du cluster EKS
resource "aws_iam_role_policy_attachment" "docdb_ssm_attachment" {
  policy_arn = aws_iam_policy.docdb_ssm_policy.arn
  role       = aws_iam_role.master.name
}

# Attachement de la politique au rôle des worker nodes (si nécessaire)
resource "aws_iam_role_policy_attachment" "docdb_ssm_worker_attachment" {
  policy_arn = aws_iam_policy.docdb_ssm_policy.arn
  role       = aws_iam_role.worker.name
}




resource "aws_iam_policy" "autoscaler" {
  name = "ed-eks-autoscaler-policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeTags",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}
resource "aws_iam_role_policy_attachment" "x-ray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_instance_profile" "worker" {
  depends_on = [aws_iam_role.worker]
  name       = "ed-eks-worker-new-profile"
  role       = aws_iam_role.worker.name
}

#Creation EKS
resource "aws_eks_cluster" "sockshop-eks" {
  name     = "${var.cluster_name}-VPC"
  role_arn = aws_iam_role.master.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = {
    "Name" = "${var.cluster_name}-VPC"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.sockshop-eks.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = var.subnet_ids
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = var.eks_worker_node_instance_type

  remote_access {
    ec2_ssh_key               = var.eks_key_pair
    source_security_group_ids = [var.eks_sg]
  }

  labels = {
    env = "dev"
  }

  scaling_config {
    desired_size = var.eks_desired_worker_node
    max_size     = var.eks_max_worker_node
    min_size     = var.eks_min_worker_node
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

/*resource "aws_security_group" "eks-sg" {
  name_prefix   = "allow_tls_"
  description   = "Allow TLS inbound traffic"
  vpc_id        = var.vpc_id

  ingress {
    description = "TLS from VPC"
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
}*/




