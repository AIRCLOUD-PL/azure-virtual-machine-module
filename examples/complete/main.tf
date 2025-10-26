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
  features {
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-vm-complete-example"
  location = "westeurope"

  tags = {
    Example     = "Complete VM"
    Environment = "Production"
    CostCenter  = "IT"
  }
}

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-vm-complete-westeu"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Storage Account for boot diagnostics
resource "azurerm_storage_account" "bootdiag" {
  name                     = "stvmdiag${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = azurerm_resource_group.example.tags
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "vnet-complete-westeu"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = azurerm_resource_group.example.tags
}

# Subnet
resource "azurerm_subnet" "vms" {
  name                 = "snet-vms"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "example" {
  name                = "nsg-vms-westeu"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/8" # Restrict to internal network
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = azurerm_resource_group.example.tags
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.vms.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Virtual Machine with all features
module "virtual_machine" {
  source = "../../"

  name                = "vm-prod-westeu-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  environment         = "prod"
  naming_prefix       = "app"
  instance_number     = "001"

  # VM Configuration
  vm_size        = "Standard_D2s_v3"
  os_type        = "Linux"
  admin_username = "azureuser"

  # Network Configuration
  subnet_id                     = azurerm_subnet.vms.id
  enable_accelerated_networking = true
  enable_ip_forwarding          = false
  private_ip_address_allocation = "Dynamic"

  # High Availability
  availability_zone = "1"

  # Source Image - Ubuntu 22.04 LTS
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Authentication
  disable_password_authentication = true
  admin_ssh_public_key            = var.ssh_public_key

  # OS Disk
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 128

  # Data Disks
  data_disks = [
    {
      lun                  = 0
      disk_size_gb         = 256
      storage_account_type = "Premium_LRS"
      caching              = "ReadWrite"
      create_option        = "Empty"
    },
    {
      lun                  = 1
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
      caching              = "ReadOnly"
      create_option        = "Empty"
    }
  ]

  # Identity
  identity_type = "SystemAssigned"

  # Security
  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true

  # Patch Management
  patch_mode            = "AutomaticByPlatform"
  patch_assessment_mode = "AutomaticByPlatform"

  # Boot Diagnostics
  enable_boot_diagnostics              = true
  boot_diagnostics_storage_account_uri = azurerm_storage_account.bootdiag.primary_blob_endpoint

  # Monitoring & Security Extensions
  enable_monitoring           = true
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.example.workspace_id
  log_analytics_workspace_key = azurerm_log_analytics_workspace.example.primary_shared_key
  enable_dependency_agent     = true
  enable_network_watcher      = true

  # Azure Policies
  enable_policy_assignments = true
  enable_backup_policy      = true

  # Cloud-init configuration
  custom_data = templatefile("${path.module}/cloud-init.yaml", {
    hostname = "vm-prod-westeu-001"
  })

  # Tags
  tags = {
    Environment  = "Production"
    ManagedBy    = "Terraform"
    CostCenter   = "IT"
    Owner        = "Platform Team"
    Compliance   = "PCI-DSS"
    BackupPolicy = "Daily"
    DataClass    = "Confidential"
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

output "data_disk_ids" {
  description = "IDs of data disks"
  value       = module.virtual_machine.data_disk_ids
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.example.id
}
