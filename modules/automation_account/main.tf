#----------------------------------------
# Deploy central automation account
#----------------------------------------
resource "azurerm_automation_account" "aa" {
  name                = "aa-hub-${var.shortcompanyname}-01"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku_name = "Basic"
  tags = {
    "Costcenter"  = "IT"
    "Environment" = "Hub"
    "Critical"    = "Yes"
    "Solution"    = "Automation-account"
  }

  #-----------------------------------------------------
  # Set diagnostic settings for Automation account
  #-----------------------------------------------------
}
resource "azurerm_monitor_diagnostic_setting" "aa" {
  name                       = "diag-hub-${var.shortcompanyname}-automation"
  target_resource_id         = azurerm_automation_account.aa.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log {
    category = "JobLogs"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "JobStreams"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "DscNodeStatus"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "AuditEvent"
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

resource "azurerm_log_analytics_linked_service" "aa-log" {
  resource_group_name = var.resource_group.name
  workspace_id        = var.log_analytics_workspace_id
  read_access_id      = azurerm_automation_account.aa.id
}
