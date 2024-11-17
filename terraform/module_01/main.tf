

# Create resource group
resource "azurerm_resource_group" "hq-ipfs-rg" {
  count    = var.use_existing_rg ? 0 : 1
  name     = var.resource_group_name
  location = var.location
  tags = {
    created_by = "jamester go"
  }
}
# End resource_group