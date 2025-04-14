
# #Création de rôle IAM pour AWS Load Balancer Controller
# resource "aws_iam_role" "aws_lb_controller" {
#   name = "${var.cluster_name}-aws-lb-controller-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.oidc_provider, "https://", "")}"
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           "StringEquals" = {
#             "${replace(var.oidc_provider, "https://", "")}:sub" = "system:serviceaccount:dev:aws-load-balancer-controller"
#           }
#         }
#       }
#     ]
#   })
#   depends_on = [ kubernetes_namespace.dev  ]
# }



# resource "aws_iam_policy" "aws_lb_controller" {
#   name        = "AWSLoadBalancerControllerPolicy"
#   description = "Policy for the AWS Load Balancer Controller"
#   policy = file("${path.module}/aws_lb_controller_policy.json")
# }

# resource "aws_iam_role_policy_attachment" "aws_lb_controller_attachment" {
#   policy_arn = aws_iam_policy.aws_lb_controller.arn
#   role       = aws_iam_role.aws_lb_controller.name
# }

# # Création du namespace "dev"
# resource "kubernetes_namespace" "dev" {
#   metadata {
#     name = "dev"
#   }
#    #
# }

# resource "kubernetes_service_account" "aws_lb_controller" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "dev"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
#     }
#   }
#    #
# }

# resource "helm_release" "aws_lb_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   version    = "1.12.0"

#   namespace = "dev"

#   values = [
#     <<EOT
#     clusterName: ${var.cluster_name}-VPC
#     serviceAccount:
#       create: false
#       name: aws-load-balancer-controller
#     EOT
#   ]

#   #timeout = 180

#   depends_on = [
#     kubernetes_service_account.aws_lb_controller,
#     aws_iam_role_policy_attachment.aws_lb_controller_attachment 
#   ]
# }


# Rôle IAM pour le Service Account Velero
resource "aws_iam_role" "velero" {
  name = "${var.cluster_name}-velero-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.oidc_provider, "https://", "")}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:velero:velero"
          }
        }
      }
    ]
  })

 depends_on = [ kubernetes_namespace.velero  ]
}

resource "aws_iam_policy" "velero" {
  name        = "${var.cluster_name}-velero-policy"
  description = "IAM policy for Velero backups on EKS"
  # Charge la politique depuis le fichier JSON externe
  policy      = jsonencode(jsondecode(replace(
    file("${path.module}/aws_velero_policy.json"),
    "__KMS_KEY_ARN__",
    aws_kms_key.velero_operators_key.arn
  )))
}

# Attacher la politique au rôle Velero
resource "aws_iam_role_policy_attachment" "velero" {
  policy_arn = aws_iam_policy.velero.arn
  role       = aws_iam_role.velero.name
  #
}

# Création du namespace "velero"
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
   #
}



# Création du Service Account Velero
resource "kubernetes_service_account" "velero" {
  metadata {
    name      = "velero"
    namespace = "velero"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.velero.arn
    }
  }
  depends_on = [aws_iam_role_policy_attachment.velero, kubernetes_namespace.velero ]
}

resource "helm_release" "velero" {
  name        = "velero"
  repository  = "https://vmware-tanzu.github.io/helm-charts"
  chart       = "velero"
  version     = "8.7.2"
  namespace   = "velero"

  set {
    name  = "credentials.useSecret"
    value = "false" # IRSA
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "velero"
  }

  # Configuration backupStorageLocations
  set {
    name  = "configuration.backupStorageLocations[0].name"
    value = "aws"
  }
  set {
    name  = "configuration.backupStorageLocations[0].provider"
    value = "aws"
  }
  set {
    name  = "configuration.backupStorageLocations[0].bucket"
    value = var.velero_bucket_name
  }
  set {
    name  = "configuration.backupStorageLocations[0].config.region"
    value = var.region
  }

  # Configuration volumeSnapshotLocations
  set {
    name  = "configuration.volumeSnapshotLocations[0].name"
    value = "aws"
  }
  set {
    name  = "configuration.volumeSnapshotLocations[0].provider"
    value = "aws"
  }
  set {
    name  = "configuration.volumeSnapshotLocations[0].config.region"
    value = var.region
  }

  # Configuration initContainers pour le plugin AWS
  set {
    name  = "initContainers[0].name"
    value = "velero-plugin-for-aws"
  }
  set {
    name  = "initContainers[0].image"
    value = "velero/velero-plugin-for-aws:v1.15.2" # Assurez-vous que la version correspond à votre version de Velero
  }
  set {
    name  = "initContainers[0].volumeMounts[0].mountPath"
    value = "/target"
  }
  set {
    name  = "initContainers[0].volumeMounts[0].name"
    value = "plugins"
  }

  force_update = true
  depends_on = [kubernetes_service_account.velero, aws_iam_role.velero ]
}

# Rôle IAM pour le Service Account percona-mongodb
resource "aws_iam_role" "percona_mongodb_role" {
  name = "${var.cluster_name}-percona-mongodb-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.oidc_provider, "https://", "")}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:percona-mongodb:percona-mongodb"
          }
        }
      }
    ]
  })
  depends_on = [ kubernetes_namespace.percona-mongodb  ]
}

# Rôle IAM pour le Service Account percona-mysql
resource "aws_iam_role" "percona_mysql_role" {
  name = "${var.cluster_name}-percona-mysql-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.oidc_provider, "https://", "")}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:percona-mysql:percona-mysql"
          }
        }
      }
    ]
  })
  depends_on = [ kubernetes_namespace.percona-mysql  ]
}

# Rôle IAM pour le Service Account redis-operator
resource "aws_iam_role" "redis_operator_role" {
  name = "${var.cluster_name}-redis-operator-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.oidc_provider, "https://", "")}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:redis-operator:redis-operator"
          }
        }
      }
    ]
  })
  depends_on = [ kubernetes_namespace.redis-operator  ]
}




# Politique IAM pour percona-mongodb
resource "aws_iam_policy" "percona_mongodb_policy" {
  name        = "${var.cluster_name}-percona-mongodb-policy"
  description = "IAM policy for percona-mongodb backups on EKS"
  policy      = jsonencode(jsondecode(replace(
    file("${path.module}/aws_percona_mongodb_policy.json"),
    "__KMS_KEY_ARN__",
    aws_kms_key.velero_operators_key.arn
  )))
}

# Politique IAM pour percona-mysql
resource "aws_iam_policy" "percona_mysql_policy" {
  name        = "${var.cluster_name}-percona-mysql-policy"
  description = "IAM policy for percona-mysql backups on EKS"
  policy      = jsonencode(jsondecode(replace(
    file("${path.module}/aws_percona_mysql_policy.json"),
    "__KMS_KEY_ARN__",
    aws_kms_key.velero_operators_key.arn
  )))
}

# Politique IAM pour redis-operator
resource "aws_iam_policy" "redis_operator_policy" {
  name        = "${var.cluster_name}-redis-operator-policy"
  description = "IAM policy for redis-operator"
  policy      = jsonencode(jsondecode(replace(
    file("${path.module}/aws_redis_operator_policy.json"),
    "__KMS_KEY_ARN__",
    aws_kms_key.velero_operators_key.arn
  )))
}




# Attacher la politique au rôle percona-mongodb
resource "aws_iam_role_policy_attachment" "percona_mongodb" {
  policy_arn = aws_iam_policy.percona_mongodb_policy.arn
  role       = aws_iam_role.percona_mongodb_role.name
}

# Attacher la politique au rôle percona-mysql
resource "aws_iam_role_policy_attachment" "percona_mysql" {
  policy_arn = aws_iam_policy.percona_mysql_policy.arn
  role       = aws_iam_role.percona_mysql_role.name
}

# Attacher la politique au rôle redis-operator
resource "aws_iam_role_policy_attachment" "redis_operator" {
  policy_arn = aws_iam_policy.redis_operator_policy.arn
  role       = aws_iam_role.redis_operator_role.name
}




# Création du namespace "percona-mongodb"
resource "kubernetes_namespace" "percona-mongodb" {
  metadata {
    name = "percona-mongodb"
  }
   #
}

# Création du Service Account percona-mongodb
resource "kubernetes_service_account" "percona-mongodb" {
  metadata {
    name      = "percona-mongodb"
    namespace = "percona-mongodb"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.percona_mongodb_role.arn
    }
  }
  depends_on = [aws_iam_role_policy_attachment.percona_mongodb, kubernetes_namespace.percona-mongodb ]
}

resource "helm_release" "percona_mongodb_operator" {
  name       = "percona-mongodb"
  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-operator"
  version    = "1.19.1" # Vérifiez la dernière version stable sur le hub Helm de Percona

  namespace = "percona-mongodb" 
  
}

# Création du namespace "percona-mysql"
resource "kubernetes_namespace" "percona-mysql" {
  metadata {
    name = "percona-mysql"
  }
  # # Assurez-vous que votre module EKS est bien référencé
}

# Création du Service Account percona-mysql
resource "kubernetes_service_account" "percona-mysql" {
  metadata {
    name      = "percona-mysql"
    namespace = "percona-mysql"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.percona_mysql_role.arn
    }
  }
  depends_on = [aws_iam_role_policy_attachment.percona_mysql, kubernetes_namespace.percona-mysql
  ]
}

resource "helm_release" "percona-mysql" {
  name       = "percona-mysql"
  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "pxc-operator"
  version    = "1.16.1"  # Choisis la version qui te convient
  
  namespace = "percona-mysql"
   #
}

# Création du namespace "redis-operator"
resource "kubernetes_namespace" "redis-operator" {
  metadata {
    name = "redis-operator"
  }
   #
}

# Création du Service Account redis-operator
resource "kubernetes_service_account" "redis-operator" {
  metadata {
    name      = "redis-operator"
    namespace = "redis-operator"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.redis_operator_role.arn
    }
  }
  depends_on = [aws_iam_role_policy_attachment.redis_operator, kubernetes_namespace.redis-operator]
}

resource "helm_release" "redis_operator" {
  name       = "redis-operator"
  repository = "https://ot-container-kit.github.io/helm-charts/"
  chart      = "redis-operator"
  version    = "0.20.0" 
  
  namespace = "redis-operator" 
 #
  
}

resource "aws_kms_key" "velero_operators_key" {
  description             = "Clé KMS pour le chiffrement des sauvegardes Velero et des données des opérateurs"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "key-default-1",
    "Statement" : [
      {
        "Sid" : "Enable IAM policies",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Velero Role",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.account_id}:role/${aws_iam_role.velero.name}"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Operator Roles",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${var.account_id}:role/${aws_iam_role.percona_mongodb_role.name}",
            "arn:aws:iam::${var.account_id}:role/${aws_iam_role.percona_mysql_role.name}",
            "arn:aws:iam::${var.account_id}:role/${aws_iam_role.redis_operator_role.name}"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}









# # Rôle IAM pour le Service Account operator_db
# resource "aws_iam_role" "operator_db" {
#   name = "${var.cluster_name}-operator_db-role"
#   assume_role_policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Principal" : {
#           "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.oidc_provider, "https://", "")}"
#         },
#         "Action" : "sts:AssumeRoleWithWebIdentity",
#         "Condition" : {
#           "StringEquals" : {
#             "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:operator_db:operator_db"
#           }
#         }
#       }
#     ]
#   })

#   # # Assurez-vous que votre module EKS est bien référencé et expose oidc_provider_arn
# }

# resource "aws_iam_policy" "operator_db" {
#   name        = "${var.cluster_name}-operator_db-policy"
#   description = "IAM policy for operator_db backups on EKS"
#   # Charge la politique depuis le fichier JSON externe
#   policy      = file("${path.module}/aws_operator_db_policy.json")
#   #
# }

# # Attacher la politique au rôle operator_db
# resource "aws_iam_role_policy_attachment" "operator_db" {
#   policy_arn = aws_iam_policy.operator_db.arn
#   role       = aws_iam_role.operator_db.name
#   #
# }










































