provider "azurerm" {
  features {
  }
  subscription_id = var.hub_subscription
}
#-------------------
# Networkwatcher
#-------------------
resource "azurerm_network_watcher" "hub-nw" {
  name                = "nw-hub-${var.shortcompanyname}-${local.location}-01"
  resource_group_name = module.resource_groups.rg["networkwatcher"].name
  location            = var.location
}


module "resource_groups" {
  source = "./modules/resource_groups"

  shortcompanyname = var.shortcompanyname
  rg_list          = var.rg_list_hub
  rg_list_nolock   = var.rg_list_nolock_hub

  environment = "hub"
  location    = var.location
}

module "hub_vnet" {
  source = "./modules/hub_vnet"

  depends_on = [
    azurerm_network_watcher.hub-nw
  ]

  hub_vnet                      = var.hub_vnet
  location                      = var.location
  fullcompanyname               = var.fullcompanyname
  shortcompanyname              = var.shortcompanyname
  resource_group_networkwatcher = module.resource_groups.rg["networkwatcher"]
  resource_group_network        = module.resource_groups.rg["networking"]
  azure_firewall                = var.azure_firewall
  bastion                       = var.bastion
  vpn_gw                        = var.vpn_gw
}

module "automation_account" {
  source = "./modules/automation_account"

  resource_group             = module.resource_groups.rg["management"]
  shortcompanyname           = var.shortcompanyname
  log_analytics_workspace_id = module.log_analytics.la
}

module "backup" {
  source = "./modules/backup"

  resource_group             = module.resource_groups.rg["backup"]
  shortcompanyname           = var.shortcompanyname
  log_analytics_workspace_id = module.log_analytics.la
}

module "keyvault" {
  source = "./modules/keyvault"

  resource_group             = module.resource_groups.rg["management"]
  shortcompanyname           = var.shortcompanyname
  log_analytics_workspace_id = module.log_analytics.la
  client_config              = data.azurerm_client_config.current
}

module "log_analytics" {
  source = "./modules/log_analytics"

  resource_group   = module.resource_groups.rg["management"]
  shortcompanyname = var.shortcompanyname
}

module "storage_account" {
  source = "./modules/storage_account"

  shortcompanyname = var.shortcompanyname
  resource_group   = module.resource_groups.rg["storage"]
}
module "rbac_roles" {
  source = "./modules/rbac_groups"
  depends_on = [
    module.resource_groups
  ]

  shortcompanyname = var.shortcompanyname
  rg_list          = concat(var.rg_list_hub, var.rg_list_nolock_hub)

  environment = "hub"
}

module "aadc" {
  count  = var.aadc == true ? 1 : 0
  source = "./modules/aadc"
  depends_on = [
    module.hub_vnet
  ]
  location         = var.location
  fullcompanyname  = var.fullcompanyname
  shortcompanyname = var.shortcompanyname
  key_vault_id     = module.keyvault.kv_id
  resource_group   = module.resource_groups.rg["aadc"]
  subnet           = module.hub_vnet.identity_subnet
  aadc_size        = var.aadc_size
  storage          = module.storage_account.bootdiag
}

module "dc" {
  count  = var.dc == true ? 1 : 0
  source = "./modules/domain_controller"
  depends_on = [
    module.hub_vnet
  ]
  location         = var.location
  fullcompanyname  = var.fullcompanyname
  shortcompanyname = var.shortcompanyname
  key_vault_id     = module.keyvault.kv_id
  resource_group   = module.resource_groups.rg["dc"]
  subnet           = module.hub_vnet.identity_subnet
  dc_size          = var.dc_size
  storage          = module.storage_account.bootdiag
  hub_vnet         = module.hub_vnet.hub_vnet
}

module "firewall" {
  source = "./modules/firewall"
  count  = var.azure_firewall == true ? 1 : 0
  depends_on = [
    module.hub_vnet,
    module.dc,
    module.aadc
  ]
  location                   = var.location
  fullcompanyname            = var.fullcompanyname
  shortcompanyname           = var.shortcompanyname
  resource_group             = module.resource_groups.rg["networking"]
  subnet                     = module.hub_vnet.firewall_subnet
  fw_tier                    = var.fw_tier
  rt-name                    = module.hub_vnet.route_table.name
  log_analytics_workspace_id = module.log_analytics.la
}

module "bastion" {
  depends_on = [
    module.firewall
  ]
  source                     = "./modules/bastion"
  count                      = var.bastion == true ? 1 : 0
  location                   = var.location
  fullcompanyname            = var.fullcompanyname
  shortcompanyname           = var.shortcompanyname
  resource_group             = module.resource_groups.rg["bastion"]
  subnet                     = module.hub_vnet.bastion_subnet
  log_analytics_workspace_id = module.log_analytics.la
  bastion_sku                = var.bastion_sku
}

module "vpn" {
  source = "./modules/vpn_gateway"
  depends_on = [
    module.bastion
  ]
  count                      = var.vpn_gw == true ? 1 : 0
  location                   = var.location
  fullcompanyname            = var.fullcompanyname
  shortcompanyname           = var.shortcompanyname
  resource_group             = module.resource_groups.rg["networking"]
  type                       = var.gateway_type
  active_active              = var.gw_active_active
  sku                        = var.gw_sku
  bgp_enabled                = var.bgp_enabled
  asn                        = var.bgp_asn
  subnet                     = module.hub_vnet.gateway_subnet
  log_analytics_workspace_id = module.log_analytics.la
  local_gateway              = var.local_gateway
}