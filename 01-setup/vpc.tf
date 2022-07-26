/**
  This file creates X number of VPCs set w/in ./variables.tf, which are used by the assigned clusters.
**/
module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  for_each     = var.demo_stages
  project_id   = var.project_id
  network_name = "${var.demo_name}-${each.value}"
  subnets = [
    {
      subnet_name   = "${var.demo_name}-${each.value}"
      subnet_ip     = "10.10.0.0/24"
      subnet_region = var.project_region
    },
  ]
}
