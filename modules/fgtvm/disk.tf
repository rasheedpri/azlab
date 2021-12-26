# Download FortiGate VHD file from Google Drive

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "null_resource" "download" {
  provisioner "local-exec" {
      command = <<-EOT
         chmod +x ~/azlab/vhd.sh
         (cd ~/azlab/ ; ./vhd.sh)
    EOT
  }
}

# Create Storage Account for FortiGate VHD File

resource "azurerm_storage_account" "fgtsa" {
  name                     = "fgtlabsa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_storage_container" "vhd" {
  name                  = "vhd"
  storage_account_name  = azurerm_storage_account.fgtsa.name
  container_access_type = "private"
}

# Upload Downloaded VHD file to Azure 

resource "azurerm_storage_blob" "vhd_file" {
  name                   = "fgt.vhd"
  storage_account_name   = azurerm_storage_account.fgtsa.name
  storage_container_name = azurerm_storage_container.vhd.name
  type                   = "Page"
  source                 = "/home/cloud/azlab/fgt.vhd"
  depends_on = [
    null_resource.download,
  ]
}

# Create Managed Disk from VHD file

resource "azurerm_managed_disk" "fgtdisk" {
  name                 = "${var.fw_name}-OS"
  location             =  var.location
  resource_group_name  =  var.resource_group_name
  storage_account_type = "Standard_LRS"
  source_uri           =  azurerm_storage_blob.vhd_file.url
  storage_account_id   =  azurerm_storage_account.fgtsa.id
  create_option        = "Import"

}
