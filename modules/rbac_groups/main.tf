locals {
  access_rights_sub = [
    "Reader",
    "Contributor",
    "Owner"
  ]

  access_rights_rg = [
    "reader",
    "contributor",
    "Owner"
  ]

  rbac_rg = distinct(flatten([
    for rg in var.rg_list : [
      for rbac in local.access_rights_rg : {
        rg   = rg
        rbac = rbac
      }
    ]
  ]))
}

data "azurerm_resource_group" "rg" {
  for_each = toset(var.rg_list)
  name = "rg-${var.environment}-${var.shortcompanyname}-${each.value}-01"
}

#----------------------------------------------
# Create RBAC groups for resource groups
#----------------------------------------------
resource "azuread_group" "rg" {
  for_each         = { for rg in local.rbac_rg : "hub.${rg.rg}.${rg.rbac}" => rg }
  display_name     = "sg-${var.environment}-${var.shortcompanyname}-${each.value.rg}-${each.value.rbac}"
  security_enabled = true
}

#---------------------------------------------
# Assign RBAC groups to resource groups
#---------------------------------------------
resource "azurerm_role_assignment" "rg" {
  for_each             = { for rg in local.rbac_rg : "hub.${rg.rg}.${rg.rbac}" => rg }
  scope                = data.azurerm_resource_group.rg["${each.value.rg}"].id
  principal_id         = azuread_group.rg["hub.${each.value.rg}.${each.value.rbac}"].id
  role_definition_name = each.value.rbac
}