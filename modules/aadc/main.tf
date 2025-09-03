#--------------------------------------------------------------------------------------------
# Create a random password that will be stored in the Key Vault as secret
# This random password will be used as admin password for the domain controllers.
#--------------------------------------------------------------------------------------------
resource "random_password" "loc-pass-aadc" {
  length = 16
}

#---------------------------------------------------------------
# Store the random created password as a KeyVault secret
#---------------------------------------------------------------
resource "azurerm_key_vault_secret" "loc_admin-aadc" {
  name         = "vm-${var.shortcompanyname}-aadc-01-adm"
  value        = random_password.loc-pass-aadc.result
  key_vault_id = var.key_vault_id
}

#------------------------------------------
# Deploy AAD server network interface
#------------------------------------------
resource "azurerm_network_interface" "nic-aadc" {
  name  = "nic-vm-${var.shortcompanyname}-aadc-01"

  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#-------------------------------
# Create AAD virtual machine
#-------------------------------
resource "azurerm_windows_virtual_machine" "aadc" {
  name  = "vm-${var.shortcompanyname}-aadc-01"

  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  network_interface_ids = [azurerm_network_interface.nic-aadc.id]

  size = var.aadc_size

  admin_username = "vm-${var.shortcompanyname}-aadc-01-adm" 
  admin_password = random_password.loc-pass-aadc.result

  os_disk {
    name                 = "vm-${var.shortcompanyname}-aadc-01-c" 
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter-smalldisk"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = var.storage.primary_blob_endpoint
  }
}

# #--------------------------------------------------------
# # Use a VM extension to set all settings on the VM
# # Script is provided by Wim Matthyssen
# #--------------------------------------------------------
# resource "azurerm_virtual_machine_extension" "os-config-dc" {
#   name                 = "osconfig"
#   virtual_machine_id   = azurerm_windows_virtual_machine.aadc.id
#   publisher            = "Microsoft.Powershell"
#   type                 = "DSC"
#   type_handler_version = "2.77"
#   settings             = <<SETTINGS
#     {
#         "fileUris": ["https://github.com/wimmatthyssen/Azure-Compute/blob/2447ae6fa64751b5cd7ed3ab9eb95cf94283a818/Set-Customized-Server-Settings-Azure-IaaS-Windows-Server-2016-2019-2022.ps1"]
#     }
# SETTINGS
#   protected_settings   = <<PROTECTED_SETTINGS
#     {
#       "commandToExecute": "Set-Customized-Server-Settings-Azure-IaaS-Windows-Server-2016-2019-2022.ps1",
#       "username": "${"vm-${var.shortcompanyname}-dc-01-adm"}",
#       "storageAccountKey": "${random_password.loc-pass-aadc.result}"
#     }
# PROTECTED_SETTINGS
# }