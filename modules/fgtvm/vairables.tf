# ResourceGroup Variables

variable "location" {}
variable "resource_group_name"  {}

# FortiGate Virtual Machine Variables
variable "fw_name"  {}
variable "nic1_subnet_id"   {}
variable "nic2_subnet_id"   {}
variable "storage_account_id"   {}

# Subnet Variables
variable "subnet_name"   {}
variable "vnet_name"  {}
variable "address_prefixes"  {}
variable "nsg_name"   {}

# NSG Rule Variables

variable "nsgrule" {
  default = [
    {
      direction    = "Outbound"},
    {
      direction    = "Inbound"
    }
  ]
}



