
resource "azurerm_lb" "web_lb" {
  name                = "AZLAB-N-WEB-LB-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "AZLAB-N-WEB-LB-01"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.web_lb_ip_ipaddress
  }
}

resource "azurerm_lb_backend_address_pool" "web_pool" {
  loadbalancer_id = azurerm_lb.web_lb.id
  name            = "WebPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "web_lb" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "${var.vm_name}${count.index + 1}-NIC"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_pool.id
  depends_on              = [azurerm_virtual_machine.websrv, azurerm_network_interface.nic]
}

resource "azurerm_lb_probe" "web_lb" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.web_lb.id
  name                = "HTTP-Probe"
  port                = 80
}

resource "azurerm_lb_rule" "web_lb" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.web_lb.id
  name                           = "WEB_Access_Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "AZLAB-N-WEB-LB-01"
  probe_id                       = azurerm_lb_probe.web_lb.id
  disable_outbound_snat          = "true"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web_pool.id, ]
}

