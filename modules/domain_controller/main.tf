#--------------------------------------------------------------------------------------------
# Create a random password that will be stored in the Key Vault as secret
# This random password will be used as admin password for the domain controllers.
#--------------------------------------------------------------------------------------------
resource "random_password" "loc-pass-dc" {
  count = 2
  length = 16
}

#---------------------------------------------------------------
# Store the random created password as a KeyVault secret
#---------------------------------------------------------------
resource "azurerm_key_vault_secret" "loc_admin-dc" {
  count = 2
  name         = "vm-${var.shortcompanyname}-dc-${count.index + 1}-adm"
  value        = random_password.loc-pass-dc["${count.index}"].result
  key_vault_id = var.key_vault_id
}

#----------------------------------------------------------------------------
# Create an availability set where the domain controllers will reside in
#----------------------------------------------------------------------------
resource "azurerm_availability_set" "avs-dc" {
  name                = "avail-hub-${var.shortcompanyname}-dc-01" # +1 is so the number is starts with 1 and not with 0
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
}

#----------------------------------------------------------------------
# Create the nic's that will be assigned to the domain controllers
#----------------------------------------------------------------------
resource "azurerm_network_interface" "nic-dc" {
  count = 2
  name  = "nic-vm-${var.shortcompanyname}-dc-${count.index + 1}" # +1 is so the number is starts with 1 and not with 0

  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#----------------------------------------------------
# Create the domain controller virtual machines
#----------------------------------------------------
resource "azurerm_windows_virtual_machine" "dc" {
  count = 2
  name  = "vm-${var.shortcompanyname}-dc-${count.index + 1}" # +1 is so the number is starts with 1 and not with 0

  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  network_interface_ids = [azurerm_network_interface.nic-dc["${count.index}"].id]

  size = var.dc_size

  admin_username = "vm-${var.shortcompanyname}-dc-${count.index + 1}-adm"
  admin_password = random_password.loc-pass-dc["${count.index}"].result

  os_disk {
    name                 = "vm-${var.shortcompanyname}-dc-${count.index + 1}-c"
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

  availability_set_id = azurerm_availability_set.avs-dc.id
  boot_diagnostics {
    storage_account_uri =var.storage.primary_blob_endpoint
  }
}

#-----------------------------------------------------
# Create the datadisks for the domain controllers
#-----------------------------------------------------
resource "azurerm_managed_disk" "datadisk" {
  count = 2
  name  = "vm-${var.shortcompanyname}-dc-${count.index + 1}-e" # +1 is so the number is starts with 1 and not with 0

  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  storage_account_type = "Premium_LRS"
  disk_size_gb         = 32
  create_option        = "Empty"
}

#--------------------------------------------------------------
# Assign the created data disks to the domain controllers
#--------------------------------------------------------------
resource "azurerm_virtual_machine_data_disk_attachment" "dc" {
  count = 2

  managed_disk_id    = azurerm_managed_disk.datadisk["${count.index}"].id
  virtual_machine_id = azurerm_windows_virtual_machine.dc["${count.index}"].id
  lun                = "1"
  caching            = "None"
}

# #--------------------------------------------------------
# # Use a VM extension to set all settings on the VM
# # Script is provided by Wim Matthyssen
# #--------------------------------------------------------
# resource "azurerm_virtual_machine_extension" "os-config-dc" {
#   count                = 2
#   name                 = "osconfig"
#   virtual_machine_id   = azurerm_windows_virtual_machine.dc["${count.index}"].id
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
#       "username": "${"vm-${var.shortcompanyname}-dc-${count.index}-adm"}",
#       "storageAccountKey": "${random_password.loc-pass-dc["${count.index}"].result}"
#     }
# PROTECTED_SETTINGS
# }

#------------------------------------------------------------------------------------------------------------------------------
# When domain controllers are deployed we will assign their private IP's as DNS servers for the VNETS
# This section only sets them for the hub network since for now we don't know how many LZ Vnet's we will deploy
#------------------------------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network_dns_servers" "dns-hub" {
  virtual_network_id = var.hub_vnet.id
  dns_servers        = ["${azurerm_windows_virtual_machine.dc["0"].private_ip_address}", "${azurerm_windows_virtual_machine.dc["1"].private_ip_address}", "168.63.129.16"]
}