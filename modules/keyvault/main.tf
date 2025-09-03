#--------------------------------------------------------------------
# Deploy a central Key Vault for storing secrets and certificates
#--------------------------------------------------------------------
resource "azurerm_key_vault" "kv-hub" {
  name                        = "kv-hub-${var.shortcompanyname}-01"
  location                    = var.resource_group.location
  resource_group_name         = var.resource_group.name
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
  enabled_for_deployment = true
  tenant_id                   = var.client_config.tenant_id
  soft_delete_retention_days  = 7

  sku_name = "standard"
  tags = {
    "Costcenter"  = "IT"
    "Critical"    = "Yes"
    "Environment" = "Hub"
    "Solution"    = "Keyvault"
  }
}

#-----------------------------------------------------------------------
# Create access policy for the object that is running this template
# This needs to be set because we need to create a secret. 
# This secret will be used as the admin password 
#-----------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "kv-ap" {
  key_vault_id = azurerm_key_vault.kv-hub.id
  tenant_id    = var.client_config.tenant_id
  object_id    = var.client_config.object_id

  secret_permissions = [
    "Get",
    "Set",
    "List",
  ]
}

#-------------------------------------------------------------
# Enable the diagnostic settings for the central KeyVault
#-------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "kv-diag" {
  name                       = "diag-hub-${var.shortcompanyname}-keyvault"
  target_resource_id         = azurerm_key_vault.kv-hub.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "AzurePolicyEvaluationDetails"
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