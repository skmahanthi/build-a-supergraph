provider "google-beta" {
  project = var.project_id
  region  = var.project_region
}
provider "google" {
  project = var.project_id
  region  = var.project_region
}
