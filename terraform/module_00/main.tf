# Start resource_group

# Create resource group
resource "azurerm_resource_group" "personal-sandbox-01" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    created_by = "jamester go"
  }
}

# End resource_group

# Start azure_storage

# Create the storage account
resource "azurerm_storage_account" "personal-sandbox-storage-acct-01" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.personal-sandbox-01.name
  location                 = azurerm_resource_group.personal-sandbox-01.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create the file share
resource "azurerm_storage_share" "personal-sandbox-storage-acct-share-01" {
  name                 = var.share_name
  storage_account_name = azurerm_storage_account.personal-sandbox-storage-acct-01.name
  quota                = 50 # GB
}

# End azure_storage

# Start create_container
resource "azurerm_container_group" "personal-sandbox-aci-01" {
  name                = var.container_name
  location            = azurerm_resource_group.personal-sandbox-01.location
  resource_group_name = azurerm_resource_group.personal-sandbox-01.name
  ip_address_type     = "Public"
  dns_name_label      = var.dns_name_label
  os_type             = "Linux"
  restart_policy      = "Always"

  container {
    name   = "ipfs"
    image  = "ipfs/go-ipfs:latest"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 4001
      protocol = "TCP"
    }
    ports {
      port     = 5001
      protocol = "TCP"
    }
    ports {
      port     = 8080
      protocol = "TCP"
    }

    volume {
      name       = "ipfs-data"
      mount_path = "/data/ipfs"
      read_only  = false
      share_name = azurerm_storage_share.personal-sandbox-storage-acct-share-01.name

      storage_account_name = azurerm_storage_account.personal-sandbox-storage-acct-01.name
      storage_account_key  = azurerm_storage_account.personal-sandbox-storage-acct-01.primary_access_key
    }
  }
}
# End container_instance

# Start manage_files_in_mounted_volume

output "container_fqdn-01" {
  value       = azurerm_container_group.personal-sandbox-aci-01.fqdn
  description = "The FQDN of the container group"
}

output "container_ip_address-01" {
  value       = azurerm_container_group.personal-sandbox-aci-01.ip_address
  description = "The IP address of the container group"
}

output "ipfs_api_address-01" {
  value       = "${azurerm_container_group.personal-sandbox-aci-01.fqdn}:5001"
  description = "The IPFS API address"
}

output "ipfs_gateway_address-01" {
  value       = "${azurerm_container_group.personal-sandbox-aci-01.fqdn}:8080"
  description = "The IPFS Gateway address"
}

# End manage_files_in_mounted_volume