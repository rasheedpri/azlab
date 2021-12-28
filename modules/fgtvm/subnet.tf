resource "azurerm_subnet" "subnet" {
    name                 = var.subnet_name
    resource_group_name  = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefixes     = var.address_prefixes
}

resource "azurerm_network_security_group" "subnet_nsg" {
    name                = var.nsg_name
    location            = var.location
    resource_group_name = var.resource_group_name
      dynamic "security_rule" {
    for_each = [for item in var.nsgrule: {
      direction              = item.direction
      }
    ]
    content {
      name                       = "Allow_${security_rule.value.direction}_Any"
      priority                   = "1001"
      direction                  = security_rule.value.direction
      destination_port_range     = "*"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
                                                                                      

resource "azurerm_subnet_network_security_group_association" "nsg_attatch" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}