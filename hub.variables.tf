variable "hub_subscription" {}
variable "fullcompanyname" {}
variable "shortcompanyname" {}
variable "location" {
  type    = string
  default = "westeurope"

  validation {
    condition = anytrue([
      var.location == "westeurope",
      var.location == "northeurope"
    ])
    error_message = "Only West and North europe as location."
  }
}
variable "hub_vnet" {
  type = string

  validation {
    condition     = cidrnetmask("${var.hub_vnet}") == "255.255.255.0"
    error_message = "Hub vnet address space should be /24."
  }
}
variable "aadc" {
  type    = bool
  default = true
}
variable "aadc_size" {
  type    = string
  default = "Standard_DS2_v2"
}
variable "dc" {
  type    = bool
  default = true
}
variable "dc_size" {
  type    = string
  default = "Standard_F2s_v2"
}
variable "azure_firewall" {
  type    = bool
  default = true
}
variable "fw_tier" {
  type    = string
  default = "Standard"
}
variable "bastion" {
  type    = bool
  default = true
}
variable "bastion_sku" {
  type    = string
  default = "Basic"
}
variable "vpn_gw" {
  type    = bool
  default = true
}
variable "gateway_type" {
  type    = string
  default = "RouteBased"
}
variable "gw_active_active" {
  type    = bool
  default = false
}
variable "gw_sku" {
  type    = string
  default = "VpnGw1"
}
variable "bgp_enabled" {
  type    = bool
  default = false
}
variable "bgp_asn" {
  type    = number
  default = null
}
variable "local_gateway" {
  type = map(object({
    name                = string
    gateway_address     = string
    address_space       = list(string)
    bgp_asn             = number
    bgp_peering_address = string
    shared_key          = string
  }))

  default = {}
}
variable "rg_list_hub" {
  type = list(string)
  default = [
    "migration",
    "dc",
    "aadc",
    "bastion",
    "management",
    "shared",
    "networkwatcher",
    "networking",
  ]
}
variable "rg_list_nolock_hub" {
  type = list(string)
  default = [
    "backup",
    "backup-irp",
    "storage",
  ]
}

variable "root_mgmt_group" {
  type    = string
  default = ""
}

variable "level1_mgmt_group" {
  type = map(object({
    display_name     = string
    subscription_ids = optional(list(string))
  }))

  default = {}
}

variable "level2_mgmt_group" {
  type = map(object({
    display_name      = string
    parent_group_name = string
    subscription_ids  = optional(list(string))
  }))

  default = {}
}

variable "level3_mgmt_group" {
  type = map(object({
    display_name      = string
    parent_group_name = string
    subscription_ids  = optional(list(string))
  }))
  default = {}
}

variable "level4_mgmt_group" {
  type = map(object({
    display_name      = string
    parent_group_name = string
    subscription_ids  = optional(list(string))
  }))
  default = {}
}

variable "level5_mgmt_group" {
  type = map(object({
    display_name      = string
    parent_group_name = string
    subscription_ids  = optional(list(string))
  }))
  default = {}
}

variable "level6_mgmt_group" {
  type = map(object({
    display_name      = string
    parent_group_name = string
    subscription_ids  = optional(list(string))
  }))
  default = {}
}