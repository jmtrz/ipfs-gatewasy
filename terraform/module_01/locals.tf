locals {
  azurerm_rg_name     = !var.use_existing_rg ? azurerm_resource_group.hq-ipfs-rg[0].name : data.azurerm_resource_group.existing[0].name
  azurerm_rg_location = !var.use_existing_rg ? azurerm_resource_group.hq-ipfs-rg[0].location : data.azurerm_resource_group.existing[0].location
}