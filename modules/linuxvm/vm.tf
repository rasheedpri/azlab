
resource "azurerm_network_interface" "nic" {
  count               = var.webvm_count
  name                = "${var.vm_name}${count.index + 1}-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "${var.vm_name}${count.index + 1}-NIC"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "websrv" {
  count                         = var.webvm_count
  name                          = "${var.vm_name}${count.index + 1}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  network_interface_ids         = [azurerm_network_interface.nic[count.index].id]
  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.vm_name}${count.index + 1}-DISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"

  }
  os_profile {
    computer_name  = "${var.vm_name}${count.index + 1}"
    admin_username = "azureuser"
    admin_password = "Mylab@1234$%"
    custom_data    = <<EOF
    #cloud-config
    packages:
        - nginx
        - postgresql
        - postgresql-contrib
    runcmd:
        - wget -P /var/www/html https://raw.githubusercontent.com/do-community/terraform-sample-digitalocean-architectures/master/01-minimal-web-db-stack/assets/index.html
        - sed -i "s/CHANGE_ME/WEB-Server-${count.index +1}/" /var/www/html/index.html
    EOF
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

}



