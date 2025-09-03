output "hub_rg" {
  value = module.resource_groups.rg["networking"]
}

output "hub_vnet" {
  value = module.hub_vnet.hub_vnet
}

output "firewall_ip" {
  value = module.firewall[0].azfw_ip
}

output "log_analytics_id" {
  value = module.log_analytics.la
}

output "hub_dns_1" {
  value = module.dc["0"].dns["0"].private_ip_address
}

output "hub_dns_2" {
  value = module.dc["0"].dns["1"].private_ip_address
}