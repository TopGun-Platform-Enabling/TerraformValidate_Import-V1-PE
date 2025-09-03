#---------------------------------------
# Deploy public IP for Azure Firewall
#---------------------------------------
resource "azurerm_public_ip" "firewall" {
  name                = "pip-hub-${var.shortcompanyname}-fw-01"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

#------------------------------------
# Deploy an empty firewall policy
#------------------------------------
resource "azurerm_firewall_policy" "policy" {
  name                = "pol-fw-${var.shortcompanyname}-01"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
}

#-------------------------
# Deploy Azure firewall
#-------------------------
resource "azurerm_firewall" "fw" {
  name                = "fw-hub-${var.shortcompanyname}-01"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku_name = "AZFW_VNet"
  sku_tier = var.fw_tier

  firewall_policy_id = azurerm_firewall_policy.policy.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

#--------------------
# Set default route
#--------------------
resource "azurerm_route" "rt-hub" {
  name                   = "DefaultRoute"
  resource_group_name    = var.resource_group.name
  route_table_name       = var.rt-name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

#-----------------------------------------------------
# Enabel Diagnostic settings for firewall public IP
#-----------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "firewall-pip-diag" {
  name                       = "diag-hub-${var.shortcompanyname}-firewall-pip"
  target_resource_id         = azurerm_public_ip.firewall.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log {
    category = "DDoSProtectionNotifications"
    enabled  = true

    retention_policy {
      enabled = true
    }

  }
  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "DDoSMitigationReports"
    enabled  = true
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }

}