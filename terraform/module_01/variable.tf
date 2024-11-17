
# Define variables
variable "resource_group_name" {
  default = "IPFS-RG"
}

variable "location" {
  default = "southeastasia"
}

variable "storage_account_name" {
  default = "hqipfsazstorage"
}

variable "share_name" {
  default = "hqipfsfileshare"
}

variable "container_name" {
  default = "hqipfsaci"
}

variable "hqipfs_gateway_auth_container_name" {
  default = "hqipfsgatewayauthaci"
}

variable "dns_name_label" {
  default = "hqipfs-gateway"
}

variable "hqipfsgateway_dns_name_label" {
  default = "hqipfs-gateway-auth"
}

variable "existing_registry_name" {
  type    = string
  default = "hqipfsacr"
}

variable "existing_resource_group_name" {
  type    = string
  default = "IPFS-RG"
}

variable "use_existing_rg" {
  description = "enable to use existing resource group"
  type        = bool
  default     = true
}

variable "use_existing_acg" {
  description = "enable users to use existing container group"
  type        = bool
  default     = false
}

variable "admin_email" {
  description = "value"
  default     = "jamester@homeqube.com"
}

#-----------------------------
# Azure Registry Image
#-----------------------------

variable "az_ipfs_image" {
  description = "ipfs/go-ipfs image stored in azure container registry"
  default     = "hqipfsacr.azurecr.io/ipfs/go-ipfs:latest"
}