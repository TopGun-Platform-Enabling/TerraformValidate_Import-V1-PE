#------------------------------------------------
# Deploy recovery services vault for Backups
#------------------------------------------------
resource "azurerm_recovery_services_vault" "rsv" {
  name                = "rsv-hub-${var.shortcompanyname}-01"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku                 = "Standard"
  soft_delete_enabled = false
}

#-----------------------------------------------------------
# Enable diagnostic settings for recovery services vault
#-----------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "rsv-diag" {
  name                       = "diag-prd-${var.shortcompanyname}-rsv"
  target_resource_id         = azurerm_recovery_services_vault.rsv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AzureBackupReport"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "CoreAzureBackup"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "AddonAzureBackupJobs"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "AddonAzureBackupAlerts"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "AddonAzureBackupPolicy"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "AddonAzureBackupStorage"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "AddonAzureBackupProtectedInstance"
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
