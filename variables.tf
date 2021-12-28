variable "location" {
  default = "eastus"
}
variable "resource_group_name" {
  default = "1-d6a2eef1-playground-sandbox"
}

variable "address_prefixes" {
  default = ["10.10.0.0/26", "10.10.0.64/26"]
}
variable "fw_name" {
  default = "AZUVNLABFGT001"
}
