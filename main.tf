module "vnet" {
  source              = "/home/cloud/azlab/modules/vnet"
  vnet_name           = "VNET-N-10.10.0.0-16"
  location            = var.location
  address_space       = ["10.10.0.0/16"]
  resource_group_name = var.resource_group_name
}

module "fgtvm" {
  source              = "/home/cloud/azlab/modules/fgtvm"
  location            = var.location
  resource_group_name = var.resource_group_name
  fw_name             = var.fw_name
  public_subnet       = var.public_subnet
  private_subnet      = var.private_subnet
  vnet_name           = module.vnet.vnet_name
}

