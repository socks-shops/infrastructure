
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




# #Création de rôle IAM pour AWS Load Balancer Controller
resource "aws_iam_role" "aws_lb_controller" {
  name = "${var.cluster_name}-aws-lb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${replace(aws_eks_cluster.sockshop-eks.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals" = {
            "${replace(aws_eks_cluster.sockshop-eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:dev:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  depends_on = [aws_iam_openid_connect_provider.eks_oidc_provider, aws_eks_node_group.node-grp,
  aws_eks_cluster.sockshop-eks
  ] 
}


resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url = aws_eks_cluster.sockshop-eks.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "9e99a64e2498cfa1988b8f2e8a9c647c4f5c02d3"
  ]
}



resource "aws_iam_policy" "aws_lb_controller" {
  name        = "AWSLoadBalancerControllerPolicy"
  description = "Policy for the AWS Load Balancer Controller"

  # Charge la politique depuis le fichier JSON externe
  policy = file("${path.module}/aws_lb_controller_policy.json")
  depends_on = [aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp]
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller_attachment" {
  policy_arn = aws_iam_policy.aws_lb_controller.arn
  role       = aws_iam_role.aws_lb_controller.name
  depends_on = [aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp]
}

#Création du namespace "dev"
resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
  depends_on = [aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp]
}

resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "dev"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
    }
  }

  depends_on = [aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp]
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.12.0"

  namespace = "dev"

  values = [
    <<EOT
    clusterName: ${var.cluster_name}-VPC
    serviceAccount:
      create: false
      name: aws-load-balancer-controller
    EOT
  ]

  #timeout = 180

  depends_on = [
    kubernetes_service_account.aws_lb_controller,
    aws_iam_role_policy_attachment.aws_lb_controller_attachment,
    aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp
  ]
}


/*resource "aws_iam_role" "aws_lb_controller" {
  name = "eks-aws-load-balancer-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}*/

/*resource "aws_iam_role_policy_attachment" "aws_lb_controller" {
  policy_arn = aws_iam_policy.aws_lb_controller.arn
  role       = aws_iam_role.aws_lb_controller.name
}*/


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


#Installer AWS Load Balancer Controller dans le cluster
# resource "null_resource" "install_aws_lb_controller" {

  
#   depends_on = [aws_eks_cluster.sockshop-eks]

#   provisioner "local-exec" {
#     command = <<EOT
#       helm repo add eks https://aws.github.io/eks-charts
#       helm repo update
#       helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
#         --set clusterName=${var.cluster_name} \
#         --set serviceAccount.create=true \
#         --set serviceAccount.name=aws-load-balancer-controller \
#         -n kube-system
#     EOT
#   }
# }

# Provider Kubernetes pour interagir avec le cluster EKS

# Ressource Helm pour installer le AWS Load Balancer Controller
/*resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.12.0"  # Utilise la version qui est compatible avec ta version d'EKS

  values = [
    <<EOT
    clusterName: ${var.cluster_name}
    serviceAccount:
      create: true
      name: aws-load-balancer-controller
    EOT
  ]

  namespace = "kube-system"
  
  depends_on = [aws_eks_cluster.sockshop-eks]  # Assure que le cluster EKS est déjà créé avant l'installation du chart
}*/




