locals {
  # Set the location abbreviation
  location = var.resource_group.location == "westeurope" ? "we" : "ne"
}