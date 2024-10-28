terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"

    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "72775a9f-cc64-494b-8592-a1ee371b1b95"
  tenant_id       = "41ee420e-e31f-4078-bbf7-4b54ad4bb4dd"
}
