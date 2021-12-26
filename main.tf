
module "vnet" {
  source              = "/home/cloud/azlab/modules/vnet"
  vnet_name           = var.vnet_name
  location            = var.location
  address_space       = var.address_space
  resource_group_name = var.resource_group_name
}

module "subnet" {
  source              = "/home/cloud/azlab/modules/subnet"
  count               = 2
  subnet_name         = format("S-%s", replace(element(var.address_prefixes, count.index), "/", "-"))
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = [var.address_prefixes[count.index]]
  nsg_name            = format("S-%s-NSG", replace(element(var.address_prefixes, count.index), "/", "-"))

}

module "fgtvm" {
  source              = "/home/cloud/azlab/modules/fgtvm"
  fw_name             = var.fw_name
  location            = var.location
  resource_group_name = var.resource_group_name
  nic1_subnet_id      = element(module.subnet.*.subnet_id, 0)
  nic2_subnet_id      = element(module.subnet.*.subnet_id, 1)
  storage_account_id  = module.fgtvm.storage_account_id
}

module  "nsgrule" {
  source                      = "/home/cloud/azlab/modules/nsgrule"
  count                       = "2"
  name                        = "Allow_Any"
  priority                    = "1001"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = element(module.subnet.*.subnet_nsg_name, count.index)
}

module  "nsgrule" {
  source                      = "/home/cloud/azlab/modules/nsgrule"
  count                       = "2"
  name                        = "Allow_Any"
  priority                    = "1001"
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = element(module.subnet.*.subnet_nsg_name, count.index)
}