
# Define variables
variable "resource_group_name" {
  default = "personal-sandbox-01"
}

variable "location" {
  default = "southeastasia"
}

variable "storage_account_name" {
  default = "psstorage00x2"
}

variable "share_name" {
  default = "psaci00x2share"
}

variable "container_name" {
  default = "psaci00x2"
}

variable "dns_name_label" {
  default = "psaci00x2-demo"
}
