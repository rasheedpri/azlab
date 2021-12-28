variable "location" {
  default = "eastus"
}
variable "resource_group_name" {
  default = "rg"
}
variable "vnet_name" {
  default = "VNET-N-10.10.0.0-16"
}
variable "address_space" {
  default = ["10.10.0.0/16"]
}
variable "address_prefixes" {
  default = ["10.10.0.0/26", "10.10.0.64/26"]
}
variable "fw_name" {
  default = "AZUVNLABFGT001"
}

variable "nsgrule_in" {
  type = list(object({
    name                        = string
    priority                    = number
    protocol                    = string
    access                      = string
    direction                   = string
    destination_port_ranges      = any
    source_address_prefix       = string
    destination_address_prefix  = string
  }))
    default = [
    {
      name                        = "Allow_Inbound_Mgmt"
      priority                    = 1001
      protocol                    = "tcp"
      access                      = "Allow"
      direction                   = "Inbound"
      destination_port_ranges     = ["22","80","443"]
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    }
  ]
}
   
variable "nsgrule_out" {
  type = list(object({
    name                        = string
    priority                    = number
    protocol                    = string
    access                      = string
    direction                   = string
    destination_port_ranges     = any
    source_address_prefix       = string
    destination_address_prefix  = string
  }))
    default = [
    {
      name                        = "Allow_Inbound_Mgmt"
      priority                    = 1001
      protocol                    = "tcp"
      access                      = "Allow"
      direction                   = "Outbound"
      destination_port_ranges     = ["22","80","443"]
      source_address_prefix       = "*"
      destination_address_prefix  = "*"
    }
  ]
}
