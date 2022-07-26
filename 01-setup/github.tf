provider "github" {
  token = var.github_token
}

// repository for K8s KRM/Terraform
resource "github_repository" "infra_repo" {
  name        = "${var.demo_name}-infrastructure"
  description = "Apollo K8s Supergraph infrastructure repository"
  visibility  = "private"
}

//TODO - add in the template param when the subgraph repos exist and are marked as templates
resource "github_repository" "subgraph_repo_1" {
  name        = "${var.demo_name}-subgraph-1"
  description = "Apollo K8s Supergraph subgraph source code repository"
  visibility  = "private"
}

resource "github_repository" "subgraph_repo_2" {
  name        = "${var.demo_name}-subgraph-2"
  description = "Apollo K8s Supergraph subgraph source code repository"
  visibility  = "private"
}
