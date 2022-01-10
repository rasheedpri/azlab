
# Fortigate Outside Load Balancer

resource "azurerm_public_ip" "fwlb_pip" {
  name                = "AZLAB-N-FGT-LB-01-PIP1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_lb" "fw_out_lb" {
  name                = "AZLAB-N-FGT-LB-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
    frontend_ip_configuration {
    name                 = "AZLAB-N-FGT-LB-01-PIP1"
    public_ip_address_id = azurerm_public_ip.fwlb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "fw_out_pool" {
  loadbalancer_id     = azurerm_lb.fw_out_lb.id
  name                = "FgtFirewallPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "fw_out_lb" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.fgt_nic1[count.index].id
  ip_configuration_name   = format("%s-NIC1", element(var.fw_name,count.index))
  backend_address_pool_id = azurerm_lb_backend_address_pool.fw_out_pool.id
  depends_on              = [azurerm_virtual_machine.fgtvm,azurerm_network_interface.fgt_nic1]
}

resource "azurerm_lb_probe" "fw_out_lb" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.fw_out_lb.id
  name                = "SSH-Probe"
  port                = 22
}

resource "azurerm_lb_rule" "fw_out_lb" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.fw_out_lb.id
  name                           = "WEB_Access_Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "AZLAB-N-FGT-LB-01-PIP1"
  probe_id                       = azurerm_lb_probe.fw_out_lb.id
  disable_outbound_snat          = "true"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.fw_out_pool.id,]
}


# Fortigate Inside Load Balancer


resource "azurerm_lb" "fw_in_lb" {
  name                = "AZLAB-N-FGT-LB-02"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "AZLAB-N-FGT-LB-02"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.0.100"
  }
}

resource "azurerm_lb_backend_address_pool" "fw_in_pool" {
  loadbalancer_id = azurerm_lb.fw_in_lb.id
  name            = "FgtFirewallPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "fw_in_lb" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = format("%s-NIC2", element(var.fw_name,count.index))
  backend_address_pool_id = azurerm_lb_backend_address_pool.fw_in_pool.id
  depends_on              = [azurerm_virtual_machine.fgtvm,azurerm_network_interface.fgt_nic2]
}

resource "azurerm_lb_probe" "fw_in_lb" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.fw_in_lb.id
  name                = "SSH-Probe"
  port                = 22
}

resource "azurerm_lb_rule" "fw_in_lb" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.fw_in_lb.id
  name                           = "FortiGateOutbound"
  protocol                       = "ALL"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "AZLAB-N-FGT-LB-02"
  probe_id                       = azurerm_lb_probe.fw_in_lb.id
  disable_outbound_snat          = "true"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.fw_in_pool.id, ]
}
