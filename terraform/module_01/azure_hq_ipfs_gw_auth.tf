
# resource "azurerm_storage_share" "hq_ipfs_gateway_auth_caddy-storage-share" {
#   name                 = "hq-ipfs-gateway-auth-caddy-data"
#   storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
#   quota                = 50
# }

resource "azurerm_storage_share" "hq_ipfs_gateway_auth_caddy-config-share" {
  name                 = "hq-ipfs-gateway-auth-caddy-config"
  storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
  quota                = 50
}

resource "azurerm_container_group" "hq_ipfs_gateway_auth_acg" {
  name                = var.hqipfs_gateway_auth_container_name
  resource_group_name = local.azurerm_rg_name
  location            = local.azurerm_rg_location
  ip_address_type     = "Public"
  dns_name_label      = var.hqipfsgateway_dns_name_label
  os_type             = "Linux"
  restart_policy      = "Always"

  image_registry_credential {
    username = data.azurerm_container_registry.acr.admin_username
    password = data.azurerm_container_registry.acr.admin_password
    server   = data.azurerm_container_registry.acr.login_server
  }

  container {
    name   = "hq-ipfs-gateway-auth"
    image  = "${data.azurerm_container_registry.acr.login_server}/hqipfsgatewayauth:latest"
    cpu    = "1.0"
    memory = "3"

    ports {
      port     = 5000
      protocol = "TCP"
    }

    environment_variables = {
      "ASPNETCORE_URLS"                     = "http://+:5000"
      "ASPNETCORE_ENVIRONMENT"              = "dev"
      "ASPNETCORE_FORWARDEDHEADERS_ENABLED" = "true"
      "TZ"                                  = "UTC"
    }
  }

  container {
    name   = "caddy"
    image  = "${data.azurerm_container_registry.acr.login_server}/caddy:latest"
    cpu    = "0.2"
    memory = "0.5"

    ports {
      port     = 443
      protocol = "TCP"
    }

    ports {
      port     = 80
      protocol = "TCP"
    }

    # volume {
    #   name       = "caddy-data"
    #   mount_path = "/data"
    #   read_only  = false
    #   share_name = azurerm_storage_share.hq_ipfs_gateway_auth_caddy-storage-share.name

    #   storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
    #   storage_account_key  = azurerm_storage_account.hq-ipfs-azure-storage.primary_access_key
    # }

    volume {
      name       = "caddy-config"
      mount_path = "/config"
      read_only  = false
      share_name = azurerm_storage_share.hq_ipfs_gateway_auth_caddy-config-share.name

      storage_account_name = azurerm_storage_account.hq-ipfs-azure-storage.name
      storage_account_key  = azurerm_storage_account.hq-ipfs-azure-storage.primary_access_key
    }

    commands = [
      "caddy",
      "reverse-proxy",
      "--from",
      "${var.hqipfsgateway_dns_name_label}.${var.location}.azurecontainer.io",
      "--to",
      "http://${var.hqipfsgateway_dns_name_label}.${var.location}.azurecontainer.io:5000"
    ]

    # environment_variables = {
    #   "DOMAIN" = "${var.hqipfsgateway_dns_name_label}.${var.location}.azurecontainer.io"
    #   "EMAIL"  = var.admin_email # Add this variable to your variables.tf
    # }
  }

  exposed_port {
    port     = 5000
    protocol = "TCP"
  }

  exposed_port {
    port     = 443
    protocol = "TCP"
  }

  tags = {
    product    = "HQ IPFS Gateway Auth"
    createdby  = "hqadmin"
    createdfor = "hq ipfs api"
  }
}
