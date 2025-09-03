#-------------------------------------
# Create public IP for vpn gateway
#-------------------------------------
resource "azurerm_public_ip" "vpn_gw" {
  name                = "pip-hub-${var.shortcompanyname}-vgw-01"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  allocation_method = "Dynamic"
}

#----------------------------------------
# Deploy the virtual network gateway
#----------------------------------------
resource "azurerm_virtual_network_gateway" "gateway" {
  name                = "gw-hub-${var.shortcompanyname}-01"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  type     = "Vpn"
  vpn_type = var.type

  active_active = var.active_active
  sku           = var.sku
  enable_bgp    = var.bgp_enabled

  ip_configuration {
    subnet_id            = var.subnet.id
    public_ip_address_id = azurerm_public_ip.vpn_gw.id
  }
}

#----------------------------------------------------------------------------------------------------------
# Create local network gateway
# Since there can be more than one local network gateways we will loop throught a map variable
#----------------------------------------------------------------------------------------------------------
resource "azurerm_local_network_gateway" "lgw" {
  for_each = { for ln in var.local_gateway : ln.name => ln }

  name                = "lgw-hub-${var.shortcompanyname}-${each.value.name}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location


  gateway_address = each.value.gateway_address
  address_space   = var.bgp_enabled == true ? null : each.value.address_space

  bgp_settings {
    asn                 = var.bgp_enabled == null ? null : each.value.bgp_asn
    bgp_peering_address = var.bgp_enabled == null ? null : each.value.bgp_peering_address
  }
}

#----------------------------------------------------------------------------------------------------------
# Connect the local network gateway to the virtual network gateway
# Since there can be more than one local network gateways we will loop throught a map variable
#----------------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network_gateway_connection" "conn" {
  for_each            = { for ln in var.local_gateway : ln.name => ln }
  name                = "conn-hub-${var.shortcompanyname}-${each.value.name}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  type = "IPsec"

  virtual_network_gateway_id = azurerm_virtual_network_gateway.gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.lgw["${each.value.name}"].id
  shared_key                 = each.value.shared_key

  enable_bgp = var.bgp_enabled
}


#-----------------------------------------------------------------------------------------------------------
#cluster config databricks
#-----------------------------------------------------------------------------------------------------------
resource "databricks_cluster" "my_cluster" {
cluster_name = "platformdp-identity-rg"
spark_version = "cluster-mvpdp-v1"
spark_env_vars = {
    PYSPARK_PYTHON = "/databricks/python3/bin/python3"
  }

