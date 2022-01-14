output "web_lb_ipaddress"    {
    value   =   azurerm_lb.web_lb.frontend_ip_configuration[0].private_ip_address
}