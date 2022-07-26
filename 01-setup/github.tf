provider "github" {
  token = var.github_token
}

// repository for K8s KRM/Terraform
resource "github_repository" "infra_repo" {
  name        = "${var.demo_name}-infrastructure"
  description = "Apollo K8s Supergraph infrastructure repository"
  visibility  = "private"
}

//TODO - identify number of repositories needed for subgraphs and update here with the appropriate number (if not 1)
resource "github_repository" "app_repo" {
  name        = "${var.demo_name}-app-source"
  description = "Apollo K8s Supergraph subgraph source code repository"
  visibility  = "private"
}
