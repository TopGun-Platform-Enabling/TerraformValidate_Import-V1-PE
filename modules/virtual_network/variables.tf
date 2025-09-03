variable "resource_group" {
  description = "The resource group where to create the VNet"
}

variable "log_analytics_id" {
  description = "The Log Analytics Workspace id"
  default     = "" 
}

variable "firewall_ip" {
  default = "Ip address of the firewall deployed in the hub"
}
variable "name" {
  description = "Name of your Azure Virtual Network"
  default     = ""
}

variable "address_space" {
  description = "The address space to be used for the Azure virtual network."
  default     = []
}

variable "dns_servers" {
  description = "List of dns servers to use for virtual network"
  default     = []
}

variable "subnets" {
  type = map(object({
    name = string
    address_prefix = list(string)
    nsg = bool
    default_route = bool
  }))
  description = "For each subnet, create an object that contain fields"
}

variable "hub_vnet" {
}

variable "hub_rg" {
  
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}