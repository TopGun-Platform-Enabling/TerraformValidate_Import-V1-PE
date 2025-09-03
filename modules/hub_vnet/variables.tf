variable "hub_vnet" {}
variable "location" {}
variable "fullcompanyname" {}
variable "shortcompanyname" {}
variable "resource_group_networkwatcher" {}
variable "resource_group_network" {}
variable "azure_firewall" {
    type = bool
    default = true
}
variable "azure_firewall_ip" {
    type = string
    default = ""
}
variable "bastion" {
  type = bool
  default = true
}
variable "vpn_gw" {
  type = bool
  default = true
}