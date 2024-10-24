resource "azurerm_user_assigned_identity" "aci_identity" {
  name                = "${var.container_name}-identity"
  resource_group_name = local.azurerm_rg_name
  location            = local.azurerm_rg_location
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aci_identity.principal_id
}