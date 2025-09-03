# #------------------------------------------
# # Create storage account for cloudshell
# #------------------------------------------
resource "azurerm_storage_account" "st-cs" {
  name                     = "stlrshub${var.shortcompanyname}cs"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  tags = {
    "Costcenter"  = "IT"
    "Environment" = "Hub"
    "Critical"    = "Yes"
    "Solution"    = "Cloudshell"
  }
}

# #------------------------------------
# # Create cloudshell storage share
# #------------------------------------
resource "azurerm_storage_share" "cloudshell" {
  name                 = "cloudshell"
  storage_account_name = azurerm_storage_account.st-cs.name
  quota                = 6
  metadata = {
    "costcenter"  = "it"
    "solution"    = "cloudshell"
    "environment" = "hub"
    "critical"    = "yes"
  }
}

# #----------------------------------------------------
# # Create a storage account for boot diagnostics
# #----------------------------------------------------
resource "azurerm_storage_account" "storage-bootdiag" {
  name                     = "stlrshub${var.shortcompanyname}bootdiagdc"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"
  tags = {
    "Costcenter"  = "It"
    "Environment" = "Hub"
    "Critical"    = "Yes"
    "Solution"    = "Boot Diagnostics-Domain Controller"
  }
}
