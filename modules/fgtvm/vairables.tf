# ResourceGroup Variables

variable "location" {}
variable "resource_group_name" {}

# FortiGate Virtual Machine Variables
variable "fw_name" {}

# Subnet Variables
variable "vnet_name" {}
variable "address_prefixes" {}

# NSG Rule Variables

variable "nsgrule" {
  default = [
    {
    direction = "Outbound" },
    {
      direction = "Inbound"
    }
  ]
}



