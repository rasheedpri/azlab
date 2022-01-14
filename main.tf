module "vnet" {
  source              = "/home/cloud/azlab/modules/vnet"
  vnet_name           = "VNET-N-10.10.0.0-16"
  location            = var.location
  address_space       = ["10.10.0.0/16"]
  resource_group_name = var.resource_group_name
}

module "firewall" {
  fw_count             = "2"
  source               = "/home/cloud/azlab/modules/fgtvm"
  location             = var.location
  resource_group_name  = var.resource_group_name
  fw_name              = var.fw_name
  public_subnet        = var.public_subnet
  private_subnet       = var.private_subnet
  private_lb_ipaddress = "10.10.0.100" 
  vnet_name            = module.vnet.vnet_name
  web_subnet           = var.web_subnet
  web_lb_ipaddress     = var.web_lb_ipaddress
}


module "websrv" {
  source              = "/home/cloud/azlab/modules/linuxvm"
  webvm_count         = "2"
  location            = var.location
  resource_group_name = var.resource_group_name
  web_subnet          = var.web_subnet
  vnet_name           = module.vnet.vnet_name
  vm_name             = "AZUVNLABWEB00"
  firewall_ip         =  module.firewall.firewall_ip
  depends_on          = [module.firewall]
  web_lb_ipaddress    = var.web_lb_ipaddress
}
