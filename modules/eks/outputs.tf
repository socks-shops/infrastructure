output "cluster_name" {
  value = aws_eks_cluster.sockshop-eks.name
}

output "node_group_name" {
  value = aws_eks_node_group.node-grp.node_group_name
}

output "oidc_provider_arn" {
  value = "arn:aws:iam::${var.account_id}:oidc-provider/${replace(aws_eks_cluster.sockshop-eks.identity[0].oidc[0].issuer, "https://", "")}"
}

output "cluster_endpoint" {
  value = aws_eks_cluster.sockshop-eks.endpoint
}
output "cluster_auth" {
  value = aws_eks_cluster.sockshop-eks.certificate_authority[0].data
}
