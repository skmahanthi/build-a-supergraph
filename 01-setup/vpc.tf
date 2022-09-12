/**
  This file creates X number of VPCs set w/in ./variables.tf, which are used by the assigned clusters.
**/
module "gcp-network" {
  source = "terraform-google-modules/network/google"
  for_each = {
    for index, stage in var.demo_stages : stage.name => stage
  }
  project_id   = var.project_id
  network_name = "${var.demo_name}-${each.value.name}"
  subnets = [
    {
      subnet_name   = "${var.demo_name}-${each.value.name}"
      subnet_ip     = each.value.subnet_range
      subnet_region = var.project_region
    }
  ]
  secondary_ranges = {
    "${var.demo_name}-${each.value.name}" = [
      {
        ip_cidr_range = each.value.ip_range_pods
        range_name    = "${var.demo_name}-${each.value.name}-pods"
      },
      {
        ip_cidr_range = each.value.ip_range_services
        range_name    = "${var.demo_name}-${each.value.name}-services"
      }
    ]
  }
}
