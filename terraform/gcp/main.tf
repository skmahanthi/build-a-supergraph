terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
   
    github = {
      source = "integrations/github"
    }
  }
}

provider "google-beta" {
  project = var.project_id
  region  = var.project_region
}
