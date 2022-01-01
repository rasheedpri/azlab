# Fortigate Public IP Address

resource "azurerm_public_ip" "fgtpip" {
  name                = "${var.fw_name}-PIP"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

}


data "azurerm_public_ip" "fgtpip" {
  name                = azurerm_public_ip.fgtpip.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_virtual_machine.fgtvm,]
}


# Fortigate Public Network Interface

resource "azurerm_network_interface" "fgt_nic1" {
  name                = "${var.fw_name}-NIC1"
  location            = var.location
  resource_group_name = var.resource_group_name
  enable_ip_forwarding= "true"

  ip_configuration {
    name                          = "${var.fw_name}-NIC1"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.fgtpip.id
  }

}

# Fortigate Private Network Interface

resource "azurerm_network_interface" "fgt_nic2" {
  name                = "${var.fw_name}-NIC2"
  location            = var.location
  resource_group_name = var.resource_group_name
  enable_ip_forwarding= "true"

  ip_configuration {
    name                          = "${var.fw_name}-NIC2"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}

# Fortigate Virtual Machine

resource "azurerm_virtual_machine" "fgtvm" {
  name                         = var.fw_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  vm_size                      = "Standard_B1ms"
  network_interface_ids        = [azurerm_network_interface.fgt_nic1.id, azurerm_network_interface.fgt_nic2.id]
  primary_network_interface_id = azurerm_network_interface.fgt_nic1.id
  depends_on = [
    azurerm_managed_disk.fgtdisk
  ]

  storage_os_disk {
    name              = azurerm_managed_disk.fgtdisk.name
    os_type           = "linux"
    caching           = "ReadWrite"
    create_option     = "Attach"
    managed_disk_id   = azurerm_managed_disk.fgtdisk.id
    managed_disk_type = "Standard_LRS"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


resource "time_sleep" "wait_180_seconds" {
  create_duration = "180s"
  depends_on = [azurerm_virtual_machine.fgtvm,]
}

# Generate bash script file

resource "local_file" "bootstrap" {
 depends_on = [time_sleep.wait_180_seconds,azurerm_virtual_machine.fgtvm,]
 filename = "/home/cloud/azlab/bootstrap.sh"
 content = <<EOF
export fgt=${data.azurerm_public_ip.fgtpip.ip_address}
user=admin
pwd=admin
  echo "============================"
  echo "Bootstraping Fortigate"
  echo "============================"
  {
  echo $pwd;
  echo $pwd;
  echo "config system interface";
  echo "edit port1";
  echo "set allowaccess https http ssh ping";
  echo "end";
  echo "config system global";
  echo "set admin-port 8080";
  echo "end"
  echo "exit"
 } | ssh -o StrictHostKeyChecking=no admin@$fgt
EOF
}

resource "local_file" "ansible_inventory" {
 depends_on = [time_sleep.wait_180_seconds,azurerm_virtual_machine.fgtvm,]
 filename = "/home/cloud/azlab/hosts"
 content = <<EOF
 
[fortigate]
fortigate01 ansible_host=${data.azurerm_public_ip.fgtpip.ip_address} ansible_user="admin" ansible_password="admin"
[fortigate:vars]
ansible_network_os=fortinet.fortios.fortios

EOF
}


resource "null_resource" "bootstrap" {
  depends_on = [time_sleep.wait_180_seconds,local_file.bootstrap,]
  provisioner "local-exec" {
    command = <<-EOT
         chmod +x ~/azlab/bootstrap.sh
         (cd ~/azlab/ ; ./bootstrap.sh)
    EOT
  }
}

resource "null_resource" "ansible_playbook1" {
  depends_on = [time_sleep.wait_180_seconds,local_file.ansible_inventory,]
  provisioner "local-exec" {
    command = <<-EOT
        ansible-playbook -i hosts forti_config.yml
    EOT
  }
}


