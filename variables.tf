variable "location" {
  default = "eastus"
}
variable "resource_group_name" {
  default = "1-035fc531-playground-sandbox"
}

variable "public_subnet" {
  default = "10.10.0.0/26"
}
variable "private_subnet" {
  default = "10.10.0.64/26"
}

variable "fw_name" {
  default = ["AZUVNLABFGT001","AZUVNLABFGT002"]
}
