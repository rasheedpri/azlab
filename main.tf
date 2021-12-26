
module "vnet" {
  vnet_name           = var.vnet_name
  location            = var.location
  address_space       = var.address_space
  resource_group_name = var.resource_group_name
}

module "subnet" {
  count               = 2
  subnet_name         = format("S-%s", replace(element(var.address_prefixes, count.index), "/", "-"))
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = [var.address_space[count.index]]
  nsg_name            = format("S-%s-NSG", replace(element(var.address_prefixes, count.index), "/", "-"))

}

module "fgtvm" {
  fw_name             = var.fw_name
  location            = var.location
  resource_group_name = var.resource_group_name
  nic1_subnet_id      = [module.subnet.*.subnet_id[0]]
  nic2_subnet_id      = [module.subnet.*.subnet_id[1]]
  storage_account_id  = module.fgtvm.storage_account_id
}


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
