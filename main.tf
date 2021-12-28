
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

module  "nsgrule_in" {
  source                      = "/home/cloud/azlab/modules/nsgrules"
  count                       = "2"
  name                        = element(var.nsgrule_in.*.name, count.index)
  priority                    = element(var.nsgrule_in.*.priority, count.index)
  direction                   = element(var.nsgrule_in.*.direction, count.index)
  access                      = element(var.nsgrule_in.*.access, count.index)
  protocol                    = element(var.nsgrule_in.*.protocol, count.index)
  destination_port_ranges     = element(var.nsgrule_in.*.destination_port_ranges, count.index)
  source_address_prefix       = element(var.nsgrule_in.*.source_address_prefix, count.index)
  destination_address_prefix  = element(var.nsgrule_in.*.destination_address_prefix, count.index)
  resource_group_name         = var.resource_group_name
  network_security_group_name = element(module.subnet.*.subnet_nsg_name, count.index)
}

module  "nsgrule_outbnd" {
  source                      = "/home/cloud/azlab/modules/nsgrules"
  count                       = "2"
  name                        = element(var.nsgrule_out.*.name, count.index)
  priority                    = element(var.nsgrule_out.*.priority, count.index)
  direction                   = element(var.nsgrule_out.*.direction, count.index)
  access                      = element(var.nsgrule_out.*.access, count.index)
  protocol                    = element(var.nsgrule_out.*.protocol, count.index)
  destination_port_ranges     = element(var.nsgrule_out.*.destination_port_ranges, count.index)
  source_address_prefix       = element(var.nsgrule_out.*.source_address_prefix, count.index)
  destination_address_prefix  = element(var.nsgrule_out.*.destination_address_prefix, count.index)
  resource_group_name         = var.resource_group_name
  network_security_group_name = element(module.subnet.*.subnet_nsg_name, count.index)
}
