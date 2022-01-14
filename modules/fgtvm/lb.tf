
# Fortigate Outside Load Balancer

resource "azurerm_public_ip" "lb_public-IP" {
  name                = "AZLAB-N-FGT-LB-01-PIP1"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_lb" "public_lb" {
  name                = "AZLAB-N-FGT-LB-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
    frontend_ip_configuration {
    name                 = "AZLAB-N-FGT-LB-01-PIP1"
    public_ip_address_id = azurerm_public_ip.lb_public-IP.id
  }
}

resource "azurerm_lb_backend_address_pool" "fw_out_pool" {
  loadbalancer_id     = azurerm_lb.public_lb.id
  name                = "FgtFirewallPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "public_lb" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.public[count.index].id
  ip_configuration_name   = format("%s-NIC1", element(var.fw_name,count.index))
  backend_address_pool_id = azurerm_lb_backend_address_pool.fw_out_pool.id
  depends_on              = [azurerm_virtual_machine.fortigate_vm,azurerm_network_interface.public]
}

resource "azurerm_lb_probe" "public_lb" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.public_lb.id
  name                = "SSH-Probe"
  port                = 22
}

resource "azurerm_lb_rule" "public_lb" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "WEB_Access_Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "AZLAB-N-FGT-LB-01-PIP1"
  probe_id                       = azurerm_lb_probe.public_lb.id
  disable_outbound_snat          = "true"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.fw_out_pool.id,]
}


# Fortigate Inside Load Balancer


resource "azurerm_lb" "private_lb" {
  name                = "AZLAB-N-FGT-LB-02"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "AZLAB-N-FGT-LB-02"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_lb_ipaddress
  }
}

resource "azurerm_lb_backend_address_pool" "fw_in_pool" {
  loadbalancer_id = azurerm_lb.private_lb.id
  name            = "FgtFirewallPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "private_lb" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.private[count.index].id
  ip_configuration_name   = format("%s-NIC2", element(var.fw_name,count.index))
  backend_address_pool_id = azurerm_lb_backend_address_pool.fw_in_pool.id
  depends_on              = [azurerm_virtual_machine.fortigate_vm,azurerm_network_interface.private]
}

resource "azurerm_lb_probe" "private_lb" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.private_lb.id
  name                = "SSH-Probe"
  port                = 22
}

resource "azurerm_lb_rule" "private_lb" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.private_lb.id
  name                           = "FortiGateOutbound"
  protocol                       = "ALL"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "AZLAB-N-FGT-LB-02"
  probe_id                       = azurerm_lb_probe.private_lb.id
  disable_outbound_snat          = "true"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.fw_in_pool.id, ]
}
