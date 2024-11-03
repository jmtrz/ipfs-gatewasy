
# Start manage_files_in_mounted_volume

output "container_fqdn-02" {
  value       = azurerm_container_group.hq_ipfs_aci.fqdn
  description = "The FQDN of the container group"
}

output "container_ip_address-02" {
  value       = azurerm_container_group.hq_ipfs_aci.ip_address
  description = "The IP address of the container group"
}

output "ipfs_api_address-02" {
  value       = "${azurerm_container_group.hq_ipfs_aci.fqdn}:5001"
  description = "The IPFS API address"
}

output "ipfs_gateway_address-02" {
  value       = "${azurerm_container_group.hq_ipfs_aci.fqdn}:8080"
  description = "The IPFS Gateway address"
}

# End manage_files_in_mounted_volume