

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

# Create the storage account
resource "azurerm_storage_account" "hq-ipfs-azure-storage" {
  name                     = var.storage_account_name
  resource_group_name      = local.azurerm_rg_name
  location                 = local.azurerm_rg_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Additional storage shares for Caddy
resource "azurerm_storage_share" "caddy-storage-share" {
  name                 = "caddy-data"
  storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
  quota                = 50
}

resource "azurerm_storage_share" "caddy-config-share" {
  name                 = "caddy-config"
  storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
  quota                = 50
}

# Create the file share
resource "azurerm_storage_share" "hq-ipfs-storage-share" {
  name                 = var.share_name
  storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
  quota                = 50 # GB
  depends_on           = [azurerm_storage_account.hq-ipfs-azure-storage]
}

# End azure_storage

# Start create_container
resource "azurerm_container_group" "hq-ipfs-aci" {
  name                = var.container_name
  resource_group_name = local.azurerm_rg_name
  location            = local.azurerm_rg_location
  ip_address_type     = "Public"
  dns_name_label      = var.dns_name_label
  os_type             = "Linux"
  restart_policy      = "Always"

  # Add registry credentials outside of the container block
  image_registry_credential {
    username = data.azurerm_container_registry.acr.admin_username
    password = data.azurerm_container_registry.acr.admin_password
    server   = data.azurerm_container_registry.acr.login_server
  }

  container {
    name   = "ipfs"
    image  = "${data.azurerm_container_registry.acr.login_server}/ipfs/go-ipfs:latest"
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
      share_name = azurerm_storage_share.hq-ipfs-storage-share.name

      storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
      storage_account_key  = azurerm_storage_account.hq-ipfs-azure-storage.primary_access_key
    }
  }
   # Caddy Container
  container {
    name   = "caddy"
    image  = "${data.azurerm_container_registry.acr.login_server}/caddy:latest"
    cpu    = "0.2"
    memory = "0.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
    ports {
      port     = 443
      protocol = "TCP"
    }

    volume {
      name       = "caddy-data"
      mount_path = "/data"
      read_only  = false
      share_name = azurerm_storage_share.caddy-storage-share.name

      storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
      storage_account_key  = azurerm_storage_account.hq-ipfs-azure-storage.primary_access_key
    }

    volume {
      name       = "caddy-config"
      mount_path = "/config"
      read_only  = false
      share_name = azurerm_storage_share.caddy-config-share.name

      storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
      storage_account_key  = azurerm_storage_account.hq-ipfs-azure-storage.primary_access_key
    }

    commands = [
      "caddy", 
      "reverse-proxy", 
      "--from",
      "${var.dns_name_label}.${var.location}.azurecontainer.io", 
      "--to", 
      "http://${var.dns_name_label}.${var.location}.azurecontainer.io:5001"
    ]

    environment_variables = {
      "DOMAIN"      = "${var.dns_name_label}.${var.location}.azurecontainer.io"
      "EMAIL"       = var.admin_email  # Add this variable to your variables.tf
    }

    # commands = [
    #   "caddy",
    #   "reverse-proxy",
    #   "--from",
    #   "${var.dns_name_label}.${var.location}.azurecontainer.io",
    #   "--to",
    #   "localhost:8080",  # IPFS Gateway
    #   "--internal-certs" # For testing. Remove for production
    # ]
  }
}
# End container_instance