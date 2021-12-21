output  "subnet_id" {
    value   =  azurerm_subnet.subnet.id
}

output "subnet_nsg_name" {
    value = azurerm_network_security_group.subnet_nsg.name
}
