variable "fullcompanyname" {}
variable "shortcompanyname" {}
variable "location" {}
variable "resource_group" {}
variable "subnet" {}
variable "log_analytics_workspace_id" {}
variable "type" {}
variable "active_active" {}
variable "sku" {}
variable "bgp_enabled" {}
variable "asn" {}
variable "local_gateway" {
  type = map(object({
    name                = string
    gateway_address     = string
    address_space       = list(string)
    bgp_asn             = number
    bgp_peering_address = string
    shared_key          = string
  }))
}