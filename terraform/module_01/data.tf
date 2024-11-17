# Start ACR authentication
data "azurerm_container_registry" "acr" {
  name                = var.existing_registry_name
  resource_group_name = local.azurerm_rg_name
}

data "azurerm_resource_group" "existing" {
  count = var.use_existing_rg ? 1 : 0
  name  = var.existing_resource_group_name
}

data "azurerm_container_group" "ipfs" {
  count               = var.use_existing_acg ? 1 : 0
  name                = var.container_name
  resource_group_name = local.azurerm_rg_name
}

locals {
  public_ip = var.use_existing_acg ? data.azurerm_container_group.ipfs[0].ip_address : azurerm_container_group.hq_ipfs_gateway_acg.ip_address
}