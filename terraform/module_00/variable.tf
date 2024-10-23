
# Define variables
variable "resource_group_name" {
  default = "personal-sandbox"
}

variable "location" {
  default = "southeastasia"
}

variable "storage_account_name" {
  default = "hqipfsstorage"
}

variable "share_name" {
  default = "hqipfsfileshare"
}

variable "container_name" {
  default = "hqipfsaci"
}

variable "dns_name_label" {
  default = "hqipfs"
}

variable "existing_resource_group_name" {
  default = "personal-sandbox"
}

variable "existing_registry_name" {
  default = "personalacr"
}

variable "use_existing_rg" {
  default = true
}

#-----------------------------
# Azure Registry Image
#-----------------------------

variable "az_ipfs_image" {
  description = "ipfs/go-ipfs image stored in azure container registry"
  default     = "hqipfsacr.azurecr.io/ipfs/go-ipfs:latest"
}