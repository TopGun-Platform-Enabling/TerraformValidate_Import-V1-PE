
# #----------------------
# # Diagnostic settings
# #----------------------
# resource "azurerm_monitor_diagnostic_setting" "hub-vnet-diag" {
#   name                       = "diag-hub-${var.shortcompanyname}-vnet"
#   target_resource_id         = azurerm_virtual_network.hub-vnet.id
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
#   log {
#     category = "VMProtectionAlerts"
#   }
#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = true
#     }
#   }
# }

#-----------
# Hub vnet
#-----------
resource "azurerm_virtual_network" "hub-vnet" {
  name                = "vnet-hub-${var.shortcompanyname}-${local.location}-01"
  resource_group_name = var.resource_group_network.name
  location            = var.resource_group_network.location
  address_space       = [var.hub_vnet]
  tags = {
    "Critical"    = "Yes"
    "Solution"    = "Vnet"
    "Costcenter"  = "It"
    "Environment" = "Hub"
    "Location"    = "${local.location}"
  }
}

#----------------------
# Create route table
#----------------------
resource "azurerm_route_table" "rt-hub" {
  name                = "rt-firewall"
  location            = var.resource_group_network.location
  resource_group_name = var.resource_group_network.name
}

#------------------
# Identity subnet
#------------------
resource "azurerm_network_security_group" "nsg-identity" {
  name                = "nsg-hub-${var.shortcompanyname}-identity-01"
  resource_group_name = var.resource_group_network.name
  location            = var.resource_group_network.location
}
resource "azurerm_subnet" "snet-identity" {
  name                 = "snet-hub-${var.shortcompanyname}-identity-01"
  address_prefixes     = ["${local.hub_cidrsubnets[5]}"]
  resource_group_name  = var.resource_group_network.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
}
resource "azurerm_subnet_network_security_group_association" "ass-identity" {
  subnet_id                 = azurerm_subnet.snet-identity.id
  network_security_group_id = azurerm_network_security_group.nsg-identity.id
}
resource "azurerm_subnet_route_table_association" "ass-identity" {
  subnet_id      = azurerm_subnet.snet-identity.id
  route_table_id = azurerm_route_table.rt-hub.id
}
#-----------------
# Shared subnet
#-----------------
resource "azurerm_network_security_group" "nsg-shared" {
  name                = "nsg-hub-${var.shortcompanyname}-shared-01"
  resource_group_name =var.resource_group_network.name
  location            = var.resource_group_network.location
}
resource "azurerm_subnet" "snet-shared" {
  name                 = "snet-hub-${var.shortcompanyname}-shared-01"
  address_prefixes     = ["${local.hub_cidrsubnets[4]}"]
  resource_group_name  = var.resource_group_network.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
}
resource "azurerm_subnet_network_security_group_association" "ass-shared" {
  subnet_id                 = azurerm_subnet.snet-shared.id
  network_security_group_id = azurerm_network_security_group.nsg-shared.id
}
resource "azurerm_subnet_route_table_association" "ass-shared" {
  subnet_id      = azurerm_subnet.snet-shared.id
  route_table_id = azurerm_route_table.rt-hub.id
}

#---------------------
# Privatelink subnet
#---------------------
resource "azurerm_subnet" "privatelink" {
    name                 = "snet-hub-${var.shortcompanyname}-privatelink-01"
  address_prefixes     = ["${local.hub_cidrsubnets[3]}"]
  resource_group_name  = var.resource_group_network.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
}

#------------------
# GatewaySubnet
#------------------
resource "azurerm_subnet" "gateway" {
  count                = var.vpn_gw == false ? 0 : 1
  name                 = "GatewaySubnet"
  address_prefixes     = ["${local.hub_cidrsubnets[2]}"]
  resource_group_name  = var.resource_group_network.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
}

#------------------
# Firewall subnet
#------------------
resource "azurerm_subnet" "firewall" {
  count                = var.azure_firewall == false ? 0 : 1
  name                 = "AzureFirewallSubnet"
  address_prefixes     = ["${local.hub_cidrsubnets[1]}"]
  resource_group_name  = var.resource_group_network.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
}


#------------------
# Bastion subnet
#------------------
resource "azurerm_subnet" "bastion" {
  count                = var.bastion == false ? 0 : 1
  name                 = "AzureBastionSubnet"
  address_prefixes     = ["${local.hub_cidrsubnets[0]}"]
  resource_group_name  = var.resource_group_network.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
}

#---------------------------------
# Create Bastion sepcific NSG's
#---------------------------------
resource "azurerm_network_security_group" "bastion" {
  count               = var.bastion == false ? 0 : 1
  name                = "nsg-hub-${var.shortcompanyname}-bastion-01"
  resource_group_name = var.resource_group_network.name
  location            = var.resource_group_network.location

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 443
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowBastionHostCommunication"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "Deny_any_other_traffic"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowSshRdpOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  security_rule {
    name                       = "AllowBastionCommunication"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"

  }
  security_rule {
    name                       = "AllowGetSessionInformation"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "Deny_Any_Other_Outbound_Traffic"
    priority                   = 900
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ass-bastion" {
  count                     = var.bastion == false ? 0 : 1
  network_security_group_id = azurerm_network_security_group.bastion[0].id
  subnet_id                 = azurerm_subnet.bastion[0].id
}