// Outputs the cluster names for each stage
output "kubernetes_cluster_names" {
  value = {
    for k, v in module.gke : k => v.name
  }
  description = "Cluster names"
}
