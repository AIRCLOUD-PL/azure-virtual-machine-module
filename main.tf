/**
 * # Azure Virtual Machine Module
 *
 * Enterprise-grade Azure Virtual Machine module with full security, monitoring, and compliance features.
 *
 * ## Features
 * - Full encryption (OS and data disks)
 * - Managed Identity support
 * - Azure Monitor integration
 * - Backup configuration
 * - Boot diagnostics
 * - Availability zones support
 * - Custom script extensions
 * - Network security
 */

locals {
  vm_name = var.name != null ? var.name : "${var.naming_prefix}-${var.environment}-${var.location}-vm-${var.instance_number}"

  # NIC name
  nic_name = var.network_interface_name != null ? var.network_interface_name : "${local.vm_name}-nic"

  # Default tags merged with custom tags
  default_tags = {
    ManagedBy   = "Terraform"
    Module      = "azure-vm"
    Environment = var.environment
    CreatedDate = timestamp()
  }

  tags = merge(local.default_tags, var.tags)

  # OS Disk name
  os_disk_name = var.os_disk_name != null ? var.os_disk_name : "${local.vm_name}-osdisk"
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = local.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address_allocation == "Static" ? var.private_ip_address : null
    public_ip_address_id          = var.public_ip_address_id
  }

  dns_servers                   = var.dns_servers
  ip_forwarding_enabled         = var.enable_ip_forwarding
  accelerated_networking_enabled = var.enable_accelerated_networking

  tags = local.tags
}

# Network Interface - Application Security Group Association
resource "azurerm_network_interface_application_security_group_association" "main" {
  count                         = var.application_security_group_id != null ? 1 : 0
  network_interface_id          = azurerm_network_interface.main.id
  application_security_group_id = var.application_security_group_id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = local.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  # Disable password authentication for Linux VMs (SSH only)
  disable_password_authentication = var.disable_password_authentication

  # SSH Key
  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.admin_ssh_public_key
    }
  }

  # Password (if enabled)
  admin_password = var.disable_password_authentication ? null : var.admin_password

  network_interface_ids = [azurerm_network_interface.main.id]

  # Availability
  availability_set_id = var.availability_set_id
  zone                = var.availability_zone

  # OS Disk
  os_disk {
    name                 = local.os_disk_name
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb

    # Encryption
    disk_encryption_set_id = var.disk_encryption_set_id

    dynamic "diff_disk_settings" {
      for_each = var.os_disk_diff_disk_settings != null ? [var.os_disk_diff_disk_settings] : []
      content {
        option    = diff_disk_settings.value.option
        placement = diff_disk_settings.value.placement
      }
    }
  }

  # Source Image
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = var.source_image_reference.publisher
      offer     = var.source_image_reference.offer
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }

  source_image_id = var.source_image_id

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  # Boot Diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  # Plan (for marketplace images)
  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  # Additional capabilities
  dynamic "additional_capabilities" {
    for_each = var.ultra_ssd_enabled ? [1] : []
    content {
      ultra_ssd_enabled = var.ultra_ssd_enabled
    }
  }

  # Encryption at host
  encryption_at_host_enabled = var.encryption_at_host_enabled

  # Patch settings
  patch_mode                                             = var.patch_mode
  patch_assessment_mode                                  = var.patch_assessment_mode
  bypass_platform_safety_checks_on_user_schedule_enabled = var.bypass_platform_safety_checks_on_user_schedule_enabled

  # License
  license_type = var.license_type

  # Security
  secure_boot_enabled = var.secure_boot_enabled
  vtpm_enabled        = var.vtpm_enabled

  # Custom data
  custom_data = var.custom_data != null ? base64encode(var.custom_data) : null
  user_data   = var.user_data != null ? base64encode(var.user_data) : null

  tags = local.tags

  depends_on = [azurerm_network_interface.main]
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "main" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = local.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.main.id]

  # Availability
  availability_set_id = var.availability_set_id
  zone                = var.availability_zone

  # OS Disk
  os_disk {
    name                 = local.os_disk_name
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb

    # Encryption
    disk_encryption_set_id = var.disk_encryption_set_id

    dynamic "diff_disk_settings" {
      for_each = var.os_disk_diff_disk_settings != null ? [var.os_disk_diff_disk_settings] : []
      content {
        option    = diff_disk_settings.value.option
        placement = diff_disk_settings.value.placement
      }
    }
  }

  # Source Image
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = var.source_image_reference.publisher
      offer     = var.source_image_reference.offer
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }

  source_image_id = var.source_image_id

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  # Boot Diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  # Plan (for marketplace images)
  dynamic "plan" {
    for_each = var.plan != null ? [var.plan] : []
    content {
      name      = plan.value.name
      product   = plan.value.product
      publisher = plan.value.publisher
    }
  }

  # Additional capabilities
  dynamic "additional_capabilities" {
    for_each = var.ultra_ssd_enabled ? [1] : []
    content {
      ultra_ssd_enabled = var.ultra_ssd_enabled
    }
  }

  # Encryption at host
  encryption_at_host_enabled = var.encryption_at_host_enabled

  # Patch settings
  patch_mode                                             = var.patch_mode
  patch_assessment_mode                                  = var.patch_assessment_mode
  bypass_platform_safety_checks_on_user_schedule_enabled = var.bypass_platform_safety_checks_on_user_schedule_enabled

  # Timezone
  timezone = var.timezone

  # License
  license_type = var.license_type

  # Security
  secure_boot_enabled = var.secure_boot_enabled
  vtpm_enabled        = var.vtpm_enabled

  # Windows Configuration
  enable_automatic_updates = var.enable_automatic_updates
  hotpatching_enabled      = var.hotpatching_enabled

  # Custom data
  custom_data = var.custom_data != null ? base64encode(var.custom_data) : null
  user_data   = var.user_data != null ? base64encode(var.user_data) : null

  tags = local.tags

  depends_on = [azurerm_network_interface.main]
}

# Data Disks
resource "azurerm_managed_disk" "data" {
  count = length(var.data_disks)

  name                 = "${local.vm_name}-datadisk-${count.index + 1}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_disks[count.index].storage_account_type
  create_option        = var.data_disks[count.index].create_option
  disk_size_gb         = var.data_disks[count.index].disk_size_gb

  # Encryption
  disk_encryption_set_id = var.disk_encryption_set_id

  # Zone
  zone = var.availability_zone

  tags = local.tags
}

# Attach Data Disks
resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count = length(var.data_disks)

  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  virtual_machine_id = var.os_type == "Linux" ? azurerm_linux_virtual_machine.main[0].id : azurerm_windows_virtual_machine.main[0].id
  lun                = var.data_disks[count.index].lun
  caching            = var.data_disks[count.index].caching
}
