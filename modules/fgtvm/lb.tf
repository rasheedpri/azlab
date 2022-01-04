
resource "azurerm_public_ip" "fwlb_pip" {
  name                = "AZLAB-N-FGT-LB-01-PIP1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_lb" "fw_lb" {
  name                = "AZLAB-N-FGT-LB-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
    frontend_ip_configuration {
    name                 = "AZLAB-N-FGT-LB-01-PIP1"
    public_ip_address_id = azurerm_public_ip.fwlb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "fw_pool" {
  loadbalancer_id     = azurerm_lb.fw_lb.id
  name                = "FgtFirewallPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "fw_lb" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.fgt_nic1[count.index].id
  ip_configuration_name   = format("%s-NIC1", element(var.fw_name,count.index))
  backend_address_pool_id = azurerm_lb_backend_address_pool.fw_pool.id
  depends_on              = [azurerm_virtual_machine.fgtvm,azurerm_network_interface.fgt_nic1]
}

resource "azurerm_lb_probe" "fw_lb" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.fw_lb.id
  name                = "SSH-Probe"
  port                = 22
}

resource "azurerm_lb_rule" "fw_lb" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.fw_lb.id
  name                           = "WEB_Access_Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "AZLAB-N-FGT-LB-01-PIP1"
  probe_id                       = azurerm_lb_probe.fw_lb.id
  disable_outbound_snat          = "true"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.fw_pool.id,]
}

