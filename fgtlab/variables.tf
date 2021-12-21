variable "vnet_name" {
  default = "VNET-10.10.0.0-16"
}
variable "location" {
  default = "eastus"
}
variable "address_space" {
  default = ["10.10.0.0/16"]
}
variable "resource_group_name" {
  default = "1-04657809-playground-sandbox"
}

variable "address_prefixes" {
  default = ["10.10.0.0/26", "10.10.0.64/26", "10.10.0.128/26"]
}

variable "vm_name" {
  default = "AZUVNWEBSRV001"
}

variable "storage_account_id" {
  default = "/subscriptions/4cedc5dd-e3ad-468d-bf66-32e31bdb9148/resourceGroups/1-04657809-playground-sandbox/providers/Microsoft.Storage/storageAccounts/rashbash"
}