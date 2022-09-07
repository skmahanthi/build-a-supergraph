# Google Service account
resource "google_service_account" "secrets-csi-k8s" {
  project      = var.project_id
  account_id   = "${substr(var.demo_name, 0, 12)}-secrets-csi-k8s"
  display_name = "${substr(var.demo_name, 0, 12)}-secrets-csi-k8s"
}

// APOLLO_KEY
resource "google_secret_manager_secret" "apollo-key" {
  project   = var.project_id
  secret_id = "${substr(var.demo_name, 0, 12)}-apollo-key"

  replication {
    user_managed {
      replicas {
        location = var.project_region
      }
    }
  }
}
resource "google_secret_manager_secret_version" "apollo-key-version" {
  secret = google_secret_manager_secret.apollo-key.id

  secret_data = var.apollo_key
}
