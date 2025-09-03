locals {
  rg = concat(var.rg_list, var.rg_list_nolock)
}
# # --------------------------------------------
# # Create resource groups based on locals
# #---------------------------------------------
resource "azurerm_resource_group" "rg" {
  for_each = toset(local.rg)
  name     = "rg-${var.environment}-${var.shortcompanyname}-${each.value}-01"
  location = var.location
  tags = {
    "Critical"    = "Yes"
    "Solution"    = each.value
    "Costcenter"  = "It"
    "Environment" = var.environment
  }
}

#------------------------------------
# Create locks on resource groups
#-------------------------------------
resource "azurerm_management_lock" "rg-lock" {
  for_each   = toset(var.rg_list)
  name       = "DoNotDeleteLock"
  scope      = azurerm_resource_group.rg[each.value].id
  lock_level = "CanNotDelete"
  notes      = "Prevent rg-${var.environment}-${var.shortcompanyname}-${each.value}-01 from deletion"
}
