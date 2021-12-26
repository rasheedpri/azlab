resource "azurerm_public_ip" "fgtpip" {
  name                = "${var.fw_name}-PIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

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

resource "azurerm_virtual_machine" "fgtvm" {
  name                  = var.fw_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  vm_size               = "Standard_B1ms"
  network_interface_ids = [azurerm_network_interface.fgt_nic1.id,azurerm_network_interface.fgt_nic2.id]
  primary_network_interface_id = azurerm_network_interface.fgt_nic1.id
  depends_on            = [
    azurerm_managed_disk.fgtdisk
    ]
  
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
