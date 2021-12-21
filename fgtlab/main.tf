module "vnet" {
  source              = "/home/cloud/azlab/modules/vnet"
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "subnet" {
  source              = "/home/cloud/azlab/modules/subnet"
  count               = "3"
  subnet_name         = format("S-%s", replace(element(var.address_prefixes, count.index), "/", "-"))
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = module.vnet.vnet_name
  address_prefixes    = [var.address_prefixes[count.index]]
  nsg_name            = format("S-%s-NSG", replace(element(var.address_prefixes, count.index), "/", "-"))
}

module "websrv" {
  source              = "/home/cloud/azlab/modules/linuxvm"
  subnet_id           = element(module.subnet.*.subnet_id, 0)
  nic_name            = "${var.vm_name}-NIC"
  vm_name             =  var.vm_name
  disk_name           = "${var.vm_name}-DISK"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "fortigate" {
  source              = "/home/cloud/azlab/modules/fortigate"
  fw_name             = "AZUVNFGT001"
  storage_account_id  = var.storage_account_id
  location            = var.location
  resource_group_name = var.resource_group_name
  nic1_subnet_id      = element(module.subnet.*.subnet_id, 1)
  nic2_subnet_id      = element(module.subnet.*.subnet_id, 2)
  fgt_subnetnsg       = element(module.subnet.*.subnet_nsg_name, 1)
}


module  "nsgrule" {
  source                      = "/home/cloud/azlab/modules/nsgrule"
  name                        = "Allow_HTTPS"
  priority                    = "1003"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = element(module.subnet.*.subnet_nsg_name, 1)
}

