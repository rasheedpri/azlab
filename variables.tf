variable "location" {
  default = "eastus"
}
variable "resource_group_name" {
  default = "rg"
}
variable "vnet_name" {
  default = "VNET-N-10.10.0.0-16"
}
variable "address_space" {
  default = ["10.10.0.0/16"]
}
variable "address_prefixes" {
  default = ["10.10.0.0/26", "10.10.0.64/24"]
}
variable "fw_name" {
  default = "AZUVNLABFGT001"
}
