resource "azurerm_subnet" "subnet" {
  count                = "2"
  name                 = format("S-%s", replace(element(var.address_prefixes, count.index), "/", "-"))
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.address_prefixes[count.index]]
}

resource "azurerm_network_security_group" "subnet_nsg" {
  count               = "2"
  name                = format("S-%s-NSG", replace(element(var.address_prefixes, count.index), "/", "-"))
  location            = var.location
  resource_group_name = var.resource_group_name
  dynamic "security_rule" {
    for_each = [for item in var.nsgrule : {
      direction = item.direction
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
  count                     = "2"
  subnet_id                 = azurerm_subnet.subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.subnet_nsg[count.index].id
}


