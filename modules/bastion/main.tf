#----------------------------------
# Deploy a public IP for bastion
#----------------------------------
resource "azurerm_public_ip" "bastion" {
  name                = "pip-hub-${var.shortcompanyname}-bas-01" # +1 is so the number is starts with 1 and not with 0
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  allocation_method = "Static"
  sku               = "Standard"

}

#-----------------------------------------------------
# Enable diagnostic settings for Bastion public IP
#-----------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "bastion-pip-diag" {
  name                       = "diag-hub-${var.shortcompanyname}-bastion-pip"
  target_resource_id         = azurerm_public_ip.bastion.id
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

#---------------------------
# Deploy the bastion host
#----------------------------
resource "azurerm_bastion_host" "bastion" {
  name                = "bas-hub-${var.shortcompanyname}-01" 
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku = var.bastion_sku

  ip_configuration {
    name                 = "ip-${var.shortcompanyname}-hub-bas"
    subnet_id            = var.subnet.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

#-------------------------------------------
# Enable diagnostic settings for bastion
#-------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "bastion-diag" {
  name                       = "diag-hub-${var.shortcompanyname}-bas"
  target_resource_id         = azurerm_bastion_host.bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "BastionAuditLogs"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}