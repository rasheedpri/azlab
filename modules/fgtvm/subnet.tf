# FortiGate Public Subnet

resource "azurerm_subnet" "public_subnet" {
  name                 = format("S-%s", replace(var.public_subnet, "/", "-"))
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.public_subnet]
}

# FortiGate Private Subnet

resource "azurerm_subnet" "private_subnet" {
  name                 = format("S-%s", replace(var.private_subnet, "/", "-"))
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.private_subnet]
}

# FortiGate Public Subnet NSG

resource "azurerm_network_security_group" "public_subnet_nsg" {
  name                = format("S-%s-NSG", replace(var.public_subnet, "/", "-"))
  location            = var.location
  resource_group_name = var.resource_group_name
}

# FortiGate Private Subnet NSG

resource "azurerm_network_security_group" "private_subnet_nsg" {
  name                = format("S-%s-NSG", replace(var.private_subnet, "/", "-"))
  location            = var.location
  resource_group_name = var.resource_group_name
}

# FortiGate Public Subnet & NSG Association

resource "azurerm_subnet_network_security_group_association" "public_nsg_attatch" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.public_subnet_nsg.id
}

# FortiGate Private Subnet & NSG Association

resource "azurerm_subnet_network_security_group_association" "private_nsg_attatch" {
  subnet_id                 = azurerm_subnet.private_subnet.id
  network_security_group_id = azurerm_network_security_group.private_subnet_nsg.id
}

# FortiGate Public Subnet NSG Rule

resource "azurerm_network_security_rule" "public_nsg_rule_out" {
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
  network_security_group_name = azurerm_network_security_group.public_subnet_nsg.name
}

resource "azurerm_network_security_rule" "public_nsg_rule_in" {
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
  network_security_group_name = azurerm_network_security_group.public_subnet_nsg.name
}

# FortiGate Private Subnet NSG Rule

resource "azurerm_network_security_rule" "private_nsg_rule_out" {
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
  network_security_group_name = azurerm_network_security_group.private_subnet_nsg.name
}

resource "azurerm_network_security_rule" "private_nsg_rule_in" {
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
  network_security_group_name = azurerm_network_security_group.private_subnet_nsg.name
}