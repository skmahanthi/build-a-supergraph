resource "google_service_account" "github-deploy-gsa" {
  project      = var.project_id
  account_id   = "github-deploy-gsa"
  display_name = "github-deploy-gsa"
}
resource "google_project_iam_binding" "github-deploy-binding" {
  project = var.project_id
  role    = "roles/container.clusterAdmin"
  members = ["serviceAccount:${google_service_account.github-deploy-gsa.email}"]
}
resource "google_service_account_key" "github-deploy-key" {
  service_account_id = google_service_account.github-deploy-gsa.name
}
resource "local_file" "github-deploy-key" {
  content  = base64decode(google_service_account_key.github-deploy-key.private_key)
  filename = "${path.module}/github-deploy-key.json"
}
