# Fortigate Public IP Address

resource "azurerm_public_ip" "PublicIP" {
  count               = var.fw_count
  name                = format("%s-PIP", element(var.fw_name,count.index))
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

}

data "azurerm_public_ip" "PublicIP" {
  count               = var.fw_count
  name                = element(azurerm_public_ip.PublicIP.*.name,count.index)
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_virtual_machine.fortigate_vm,]
}

# Fortigate Public Network Interface

resource "azurerm_network_interface" "public" {
  count               = var.fw_count
  name                = format("%s-NIC1", element(var.fw_name,count.index))
  location            = var.location
  resource_group_name = var.resource_group_name
  enable_ip_forwarding= "true"

  ip_configuration {
    name                          = format("%s-NIC1", element(var.fw_name,count.index))
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PublicIP[count.index].id
  }

}

# Fortigate Private Network Interface

resource "azurerm_network_interface" "private" {
  count               = var.fw_count
  name                = format("%s-NIC2", element(var.fw_name,count.index))
  location            = var.location
  resource_group_name = var.resource_group_name
  enable_ip_forwarding= "true"

  ip_configuration {
    name                          = format("%s-NIC2", element(var.fw_name,count.index))
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}

# Fortigate Virtual Machine

resource "azurerm_virtual_machine" "fortigate_vm" {
  count                        = var.fw_count
  name                         = element(var.fw_name,count.index)
  location                     = var.location
  resource_group_name          = var.resource_group_name
  vm_size                      = "Standard_B1ms"
  network_interface_ids        = [azurerm_network_interface.public[count.index].id, 
                                  azurerm_network_interface.private[count.index].id]
  primary_network_interface_id = azurerm_network_interface.public[count.index].id
  depends_on = [
    azurerm_managed_disk.fgtdisk
  ]

  storage_os_disk {
    name              = azurerm_managed_disk.fgtdisk[count.index].name
    os_type           = "linux"
    caching           = "ReadWrite"
    create_option     = "Attach"
    managed_disk_id   = azurerm_managed_disk.fgtdisk[count.index].id
    managed_disk_type = "Standard_LRS"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


resource "time_sleep" "wait_180_seconds" {
  create_duration = "180s"
  depends_on = [azurerm_virtual_machine.fortigate_vm,]
}

# Generate bash script file to bootstrap FortiGate

resource "local_file" "bootstrap" {
    count       =  var.fw_count
    content     =  templatefile("${path.cwd}/bootstrap.tftpl", {fortigate_ip = "${element(data.azurerm_public_ip.PublicIP.*.ip_address, count.index)}"})
    filename    = "${path.cwd}/bootsrap${count.index + 1}.sh"
}

# Generate ansible inventory file

resource "local_file" "ansible_inventory" {
    content     =  templatefile(
                    "${path.cwd}/hosts.tftpl", {
                     hostname = "AZUVNLABFGT00", fortigate_ip =  "${data.azurerm_public_ip.PublicIP.*.ip_address}",                   
                     })
    filename    = "${path.cwd}/hosts.ini"
    depends_on = [time_sleep.wait_180_seconds,azurerm_virtual_machine.fortigate_vm,]
}



resource "null_resource" "bootstrap" {
  count      = var.fw_count
  depends_on = [time_sleep.wait_180_seconds,local_file.bootstrap,]
  
  provisioner "local-exec" {
    command = <<-EOT
         chmod +x "${path.cwd}/bootsrap${count.index + 1}.sh"
         (cd ${path.cwd} ; ./bootsrap${count.index + 1}.sh)
    EOT
  }
}

resource "local_file" "ansible_vars" {
    content     =  templatefile(
                   "${path.cwd}/ansible.tftpl", {
                    web_lb_ipaddress = "${var.web_lb_ipaddress}",
                    web_subnet       = "${var.web_subnet}"
                    
                    })
    filename    = "${path.cwd}/group_vars/fortigate.yml"
}



resource "null_resource" "ansible_play" {
  depends_on = [time_sleep.wait_180_seconds,local_file.ansible_inventory,]
  provisioner "local-exec" {
    command = <<-EOT
        ansible-playbook fgconfig.yml
    EOT
  }
}

