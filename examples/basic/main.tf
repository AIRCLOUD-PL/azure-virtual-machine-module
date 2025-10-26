terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-vm-basic-example"
  location = "westeurope"

  tags = {
    Example = "Basic VM"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-example-westeu"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "snet-vms"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Virtual Machine Module
module "virtual_machine" {
  source = "../../"

  name                = "vm-basic-westeu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  environment         = "dev"

  # VM Configuration
  vm_size        = "Standard_B2s"
  os_type        = "Linux"
  admin_username = "azureuser"

  # Network
  subnet_id = azurerm_subnet.example.id

  # Source Image - Ubuntu 22.04 LTS
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # SSH Authentication
  disable_password_authentication = true
  admin_ssh_public_key            = file("~/.ssh/id_rsa.pub")

  # Managed Identity
  identity_type = "SystemAssigned"

  # Boot Diagnostics
  enable_boot_diagnostics = true

  tags = {
    Example     = "Basic"
    Environment = "Development"
  }
}

# Outputs
output "vm_id" {
  description = "ID of the virtual machine"
  value       = module.virtual_machine.vm_id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = module.virtual_machine.vm_name
}

output "private_ip_address" {
  description = "Private IP address"
  value       = module.virtual_machine.private_ip_address
}

output "identity_principal_id" {
  description = "Principal ID of managed identity"
  value       = module.virtual_machine.identity_principal_id
}
