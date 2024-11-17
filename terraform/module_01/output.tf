
# Start manage_files_in_mounted_volume

output "hqipfs_gateway_container_fqdn" {
  value       = azurerm_container_group.hq_ipfs_gateway_acg.fqdn
  description = "The FQDN of the container group"
}

output "hqipfs_gateway_container_ip_address" {
  value       = azurerm_container_group.hq_ipfs_gateway_acg.ip_address
  description = "The IP address of the container group"
}

output "hqipfs_gateway_api_address" {
  value       = "${azurerm_container_group.hq_ipfs_gateway_acg.fqdn}:5001"
  description = "The IPFS API address"
}

output "hqipfs_gateway_address" {
  value       = "${azurerm_container_group.hq_ipfs_gateway_acg.fqdn}:8080"
  description = "The IPFS Gateway address"
}

# output "hqipfs_gateway_auth_container_fqdn" {
#   value       = azurerm_container_group.hq_ipfs_gateway_auth_acg.fqdn
#   description = "The FQDN of the hqipfs-gateway-auth container group"
# }

# output "hqipfs_gateway_auth_container_ip_address" {
#   value       = azurerm_container_group.hq_ipfs_gateway_auth_acg.ip_address
#   description = "The IP address of the hqipfs-gateway-auth container group"
# }


# End manage_files_in_mounted_volume