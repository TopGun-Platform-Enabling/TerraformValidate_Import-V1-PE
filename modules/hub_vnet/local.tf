locals {
      # Set the location abbreviation
  location = var.location == "westeurope" ? "we" : "ne"


    # This function enables us to provide a single /24 from where the hub subnets can be calculated and created.
  hub_cidrsubnets = cidrsubnets("${var.hub_vnet}", 2, 2, 2, 3, 4, 5)
}