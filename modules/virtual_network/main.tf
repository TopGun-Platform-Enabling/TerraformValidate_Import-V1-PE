terraform {
  experiments = [module_variable_optional_attrs]
}
#------------------------
# Local declarations
#------------------------
# locals {
#   diag_nsg = {for k,v in var.subnets : k => v.diag_nsg_name if v.diag_nsg_name != ""}
# }


#-------------------------------------
# VNET Creation - Default is "true"
#-------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = merge({ "Solution" = "Vnet" }, var.tags, )
}

resource "azurerm_subnet" "snet" {
  for_each                                       = var.subnets
  name                                           = each.value.name
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = each.value.address_prefix
}

#-----------------------------------------------
# NSG deployment
#-----------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each            = { for k, v in var.subnets : k => v if v.nsg == true}
  name                = "nsg-${each.value.name}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
}

resource "azurerm_subnet_network_security_group_association" "nsg-assoc" {
  for_each                  = { for k, v in var.subnets : k => v if v.nsg == true}
  subnet_id                 = azurerm_subnet.snet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

#----------------------------
# Route table deployment
#----------------------------
resource "azurerm_route_table" "rt" {
  for_each            = { for k, v in var.subnets : k => v if v.default_route == true}
  name = "rt-${each.value.name}"
  resource_group_name = var.resource_group.name
  location = var.resource_group.location
  route {
    name = "Default"
    address_prefix = "0.0.0.0/0"
    next_hop_type = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_ip
  }
}

resource "azurerm_subnet_route_table_association" "rt-assoc" {
  for_each = { for k, v in var.subnets : k => v if v.default_route == true}
  subnet_id = azurerm_subnet.snet[each.key].id
  route_table_id = azurerm_network_security_group.nsg[each.key].id
}

#---------------------------------
# Peering to hub vnet
#---------------------------------
data "azurerm_virtual_network" "hub" {
  name = var.hub_vnet
  resource_group_name = var.hub_rg
}
resource "azurerm_virtual_network_peering" "vnet-hub" {
  name = "peer-${azurerm_virtual_network.vnet.name}-${data.azurerm_virtual_network.hub.name}" 
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
}

resource "azurerm_virtual_network_peering" "hub-vnet" {
  name = "peer-${data.azurerm_virtual_network.hub.name}-${azurerm_virtual_network.vnet.name}" 
  resource_group_name = data.azurerm_virtual_network.hub.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}
# -----------------------------------------------------------------------
# Configure Diagnostic Settings for VNet + Network Security Groups
# -----------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "diag-vnet" {
  name ="diag-${azurerm_virtual_network.vnet.name}"
  target_resource_id = azurerm_virtual_network.vnet.id
  log_analytics_workspace_id = var.log_analytics_id
  
  log {
    category = "VMProtectionAlerts"
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
  
}

resource "azurerm_monitor_diagnostic_setting" "diag-nsg" {
    for_each                  = { for k, v in var.subnets : k => v if v.nsg == true}
    name =  "diag-nsg-${each.value.name}"
    target_resource_id = azurerm_network_security_group.nsg[each.key].id
    log_analytics_workspace_id = var.log_analytics_id

    log {
        category = "NetworkSecurityGroupEvent"
        enabled  = true

        retention_policy {
          enabled = true
        }
    }
    log {
        category = "NetworkSecurityGroupRuleCounter"
        enabled = true

        retention_policy {
          enabled =true
        }
    }
}