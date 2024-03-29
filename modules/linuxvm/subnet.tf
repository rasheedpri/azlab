#  Subnet

resource "azurerm_subnet" "subnet" {
  name                 = format("S-%s", replace(var.address_prefixes, "/", "-"))
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.address_prefixes]
}


# Subnet NSG

resource "azurerm_network_security_group" "subnet_nsg" {
  name                = format("S-%s-NSG", replace(var.address_prefixes, "/", "-"))
  location            = var.location
  resource_group_name = var.resource_group_name
}


# NSG Association

resource "azurerm_subnet_network_security_group_association" "nsg_attatch" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.subnet_nsg.id
}

resource "azurerm_route_table" "udr" {
  name                          = "web-outbound"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.0.68"
  }
}

resource "azurerm_subnet_route_table_association" "udr_attach" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.udr.id
}

# Subnet NSG Rule

resource "azurerm_network_security_rule" "nsg_rule_out" {
  name                        = "Allow_Outbound_Any"
  priority                    = 1001
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}

resource "azurerm_network_security_rule" nsg_rule_in {
  name                        = "Allow_Inbound_Any"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.subnet_nsg.name
}

