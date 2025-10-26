/**
 * Naming conventions following Microsoft Cloud Adoption Framework (CAF)
 * https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming
 */

locals {
  # Naming convention patterns
  naming_conventions = {
    virtual_machine = {
      pattern    = "{workload}-{environment}-{region}-vm-{instance}"
      example    = "web-prod-westeu-vm-001"
      max_length = 64 # Linux: 64, Windows: 15
    }

    network_interface = {
      pattern    = "{vm-name}-nic-{instance}"
      example    = "web-prod-westeu-vm-001-nic-001"
      max_length = 80
    }

    os_disk = {
      pattern    = "{vm-name}-osdisk"
      example    = "web-prod-westeu-vm-001-osdisk"
      max_length = 80
    }

    data_disk = {
      pattern    = "{vm-name}-datadisk-{instance}"
      example    = "web-prod-westeu-vm-001-datadisk-001"
      max_length = 80
    }
  }

  # Region abbreviations
  region_abbreviations = {
    "eastus"             = "eus"
    "eastus2"            = "eus2"
    "westus"             = "wus"
    "westus2"            = "wus2"
    "westus3"            = "wus3"
    "centralus"          = "cus"
    "northcentralus"     = "ncus"
    "southcentralus"     = "scus"
    "westcentralus"      = "wcus"
    "northeurope"        = "neu"
    "westeurope"         = "weu"
    "uksouth"            = "uks"
    "ukwest"             = "ukw"
    "francecentral"      = "frc"
    "francesouth"        = "frs"
    "germanywestcentral" = "gwc"
    "switzerlandnorth"   = "chn"
    "norwayeast"         = "noe"
    "polandcentral"      = "plc"
  }

  # Environment abbreviations
  environment_abbreviations = {
    "production"  = "prod"
    "staging"     = "stg"
    "development" = "dev"
    "testing"     = "test"
    "qa"          = "qa"
    "dr"          = "dr"
    "sandbox"     = "sbx"
  }

  # Resource type abbreviations (as per Microsoft CAF)
  resource_abbreviations = {
    "virtual-machine"        = "vm"
    "network-interface"      = "nic"
    "public-ip"              = "pip"
    "network-security-group" = "nsg"
    "virtual-network"        = "vnet"
    "subnet"                 = "snet"
    "managed-disk"           = "disk"
    "availability-set"       = "avail"
  }

  # Helper function to get abbreviated region
  region_short = lookup(local.region_abbreviations, var.location, substr(var.location, 0, 5))

  # Helper function to get abbreviated environment
  env_short = lookup(local.environment_abbreviations, lower(var.environment), substr(var.environment, 0, 4))

  # Validation: Windows VM names must be 15 characters or less
  is_windows_name_valid = var.os_type == "Windows" ? length(local.vm_name) <= 15 : true
}

# Outputs for naming conventions (for documentation)
output "naming_convention_pattern" {
  description = "Naming convention pattern used"
  value       = local.naming_conventions.virtual_machine.pattern
}

output "naming_convention_example" {
  description = "Naming convention example"
  value       = local.naming_conventions.virtual_machine.example
}
