# Generate bash script file

resource "local_file" "apache_install" {
 count      = var.webvm_count
 filename = "/home/cloud/azlab/apache-install0${count.index + 1}.sh"
 content = <<EOF
  #! /bin/bash
  sudo apt-get update
  sudo apt-get install -y apache2
  sudo systemctl start apache2
  sudo systemctl enable apache2
  echo "<h1>Your Automation is Successfull - WEB-SRV-0${count.index + 1}</h1>" | sudo tee /var/www/html/index.html
EOF
}


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
  count                 = var.webvm_count
  depends_on            = [local_file.apache_install,]  
  name                  = "${var.vm_name}${count.index + 1}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  vm_size               = "Standard_DS1_v2"


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
    custom_data    = file("apache-install0${count.index + 1}.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

}



