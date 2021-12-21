terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "azurerm_storage_container" "vhd" {
  name                  = "vhd"
  storage_account_name  = "rashbash"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "vhd_file" {
  name                   = "fgt.vhd"
  storage_account_name   = "rashbash"
  storage_container_name = azurerm_storage_container.vhd.name
  type                   = "Page"
  source                 = "/home/cloud/vhd/fgt.vhd"
}
