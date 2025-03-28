output "cluster_endpoint" {
  value       = aws_docdb_cluster.docdb_cluster.endpoint
  description = "Cluster endpoint to connect to DocumentDB"
}

output "reader_endpoint" {
  value       = aws_docdb_cluster.docdb_cluster.reader_endpoint
  description = "Reader endpoint to connect for read replicas"
}


output "cluster_id" {
  value       = aws_docdb_cluster.docdb_cluster.id
  description = "ID of the DocumentDB cluster"
}