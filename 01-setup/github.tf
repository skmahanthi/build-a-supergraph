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
resource "github_repository" "subgraph_repo_a" {
  name        = "${var.demo_name}-subgraph-a"
  description = "Apollo K8s Supergraph subgraph source code repository"
  visibility  = "private"
}

resource "github_repository" "subgraph_repo_b" {
  name        = "${var.demo_name}-subgraph-b"
  description = "Apollo K8s Supergraph subgraph source code repository"
  visibility  = "private"
}

resource "google_service_account" "github-deploy-gsa" {
  project      = var.project_id
  account_id   = "github-deploy-gsa"
  display_name = "github-deploy-gsa"
}
resource "google_project_iam_binding" "github-deploy-binding" {
  project = var.project_id
  role    = "roles/container.developer"
  members = ["serviceAccount:${google_service_account.github-deploy-gsa.email}"]
}
resource "google_service_account_key" "github-deploy-key" {
  service_account_id = google_service_account.github-deploy-gsa.name
}
resource "local_file" "github-deploy-key" {
  content  = base64decode(google_service_account_key.github-deploy-key.private_key)
  filename = "${path.module}/github-deploy-key.json"
}
