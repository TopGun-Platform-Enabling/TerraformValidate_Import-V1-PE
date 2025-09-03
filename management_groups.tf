data "azurerm_subscription" "current" {}

locals {
  tenant_root_group_id = "/providers/Microsoft.Management/managementGroups/${data.azurerm_subscription.current.tenant_id}"
}

resource "azurerm_management_group" "root" {
  display_name               = "mg-${var.shortcompanyname}-root"
  parent_management_group_id = local.tenant_root_group_id
}

resource "azurerm_management_group" "level1" {
  for_each                   = var.level1_mgmt_group
  display_name               = "mg-${var.shortcompanyname}-${each.value.display_name}"
  parent_management_group_id = azurerm_management_group.root.id
  subscription_ids           = each.value.subscription_ids
}

resource "azurerm_management_group" "level2" {
  for_each                   = var.level2_mgmt_group
  display_name               = "mg-${var.shortcompanyname}-${each.value.display_name}"
  parent_management_group_id = azurerm_management_group.level1[each.value.parent_group_name].id
  subscription_ids           = each.value.subscription_ids
}

resource "azurerm_management_group" "level3" {
  for_each                   = var.level3_mgmt_group
  display_name               = "mg-${var.shortcompanyname}-${each.value.display_name}"
  parent_management_group_id = azurerm_management_group.level2[each.value.parent_group_name].id
  subscription_ids           = each.value.subscription_ids
}

resource "azurerm_management_group" "level4" {
  for_each                   = var.level4_mgmt_group
  display_name               = "mg-${var.shortcompanyname}-${each.value.display_name}"
  parent_management_group_id = azurerm_management_group.level3[each.value.parent_group_name].id
  subscription_ids           = each.value.subscription_ids
}

resource "azurerm_management_group" "level5" {
  for_each                   = var.level5_mgmt_group
  display_name               = "mg-${var.shortcompanyname}-${each.value.display_name}"
  parent_management_group_id = azurerm_management_group.level4[each.value.parent_group_name].id
  subscription_ids           = each.value.subscription_ids
}

resource "azurerm_management_group" "level6" {
  for_each                   = var.level6_mgmt_group
  display_name               = each.value.display_name
  parent_management_group_id = azurerm_management_group.level5[each.value.parent_group_name].id
  subscription_ids           = each.value.subscription_ids
}