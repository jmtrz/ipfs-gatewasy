# Start ACR authentication
data "azurerm_container_registry" "acr" {
  name                = var.existing_registry_name
  resource_group_name = local.azurerm_rg_name
}

data "azurerm_resource_group" "existing" {
  count = var.use_existing_rg ? 1 : 0  
  name  = var.existing_resource_group_name
}
