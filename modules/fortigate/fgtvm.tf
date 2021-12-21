resource "azurerm_managed_disk" "fgtdisk" {
  name                 = "${var.fw_name}-OS"
  location             =  var.location
  resource_group_name  =  var.resource_group_name
  storage_account_type = "Standard_LRS"
  source_uri           = "https://rashbash.blob.core.windows.net/vhd/fgt.vhd"
  storage_account_id   =  var.storage_account_id
  create_option        = "Import"

}


resource "azurerm_public_ip" "fgtpip" {
  name                = "${var.fw_name}-PIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

}

resource "azurerm_network_security_group" "fgtnsg" {
  name                = "${var.fw_name}-NSG"
  location            = "eastus"
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow_SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface" "fgt_nic1" {
  name                = "${var.fw_name}-NIC1"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.fw_name}-NIC1"
    subnet_id                     = var.nic1_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.fgtpip.id
  }

}

resource "azurerm_network_interface" "fgt_nic2" {
  name                = "${var.fw_name}-NIC2"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.fw_name}-NIC2"
    subnet_id                     =  var.nic2_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_interface_security_group_association" "fgt_nic1" {
  network_interface_id      = azurerm_network_interface.fgt_nic1.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}

resource "azurerm_network_interface_security_group_association" "fgt_nic2" {
  network_interface_id      = azurerm_network_interface.fgt_nic2.id
  network_security_group_id = azurerm_network_security_group.fgtnsg.id
}


resource "azurerm_virtual_machine" "fgtvm" {
  name                  = var.fw_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  vm_size               = "Standard_B1ms"
  network_interface_ids = [azurerm_network_interface.fgt_nic1.id,azurerm_network_interface.fgt_nic2.id]
  primary_network_interface_id = azurerm_network_interface.fgt_nic1.id
  
  storage_os_disk {
    name               = azurerm_managed_disk.fgtdisk.name
    os_type            = "linux"
    caching            = "ReadWrite"
    create_option      = "Attach"
    managed_disk_id    = azurerm_managed_disk.fgtdisk.id
    managed_disk_type  = "Standard_LRS"
  }


  os_profile_linux_config {
    disable_password_authentication = false
  }
}


resource "azurerm_network_security_rule" "fgtnsg_rule1" {
  name                        = "Allow_HTTP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.fgtnsg.name
}

resource "azurerm_network_security_rule" "subnet_rule1" {
  name                        = "Allow_SSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.fgt_subnetnsg
}

resource "azurerm_network_security_rule" "subnet_rule2" {
  name                        = "Allow_HTTP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.fgt_subnetnsg
}