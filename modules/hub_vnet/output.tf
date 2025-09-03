output "hub_vnet" {
  value = azurerm_virtual_network.hub-vnet
}

output "identity_subnet" {
  value = azurerm_subnet.snet-identity
}

output "shared_subnet" {
  value = azurerm_subnet.snet-shared
}

output "privatelink_subnet" {
  value = azurerm_subnet.privatelink
}

output "gateway_subnet" {
  value = azurerm_subnet.gateway[0]
}

output "firewall_subnet" {
  value = azurerm_subnet.firewall[0]
}

output "bastion_subnet" {
  value = azurerm_subnet.bastion[0]
}

output "route_table" {
  value = azurerm_route_table.rt-hub
}