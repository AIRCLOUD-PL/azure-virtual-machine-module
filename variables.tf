variable "name" {
  description = "Name of the virtual machine. If null, will be auto-generated based on naming convention."
  type        = string
  default     = null
}

variable "naming_prefix" {
  description = "Prefix for resource naming when auto-generating names"
  type        = string
  default     = "vm"
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, test)"
  type        = string
}

variable "instance_number" {
  description = "Instance number for the VM (used in auto-generated names)"
  type        = string
  default     = "001"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vm_size" {
  description = "Size of the Virtual Machine (e.g., Standard_D2s_v3)"
  type        = string
}

variable "os_type" {
  description = "Operating system type: Linux or Windows"
  type        = string
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
  }
}

# Network Configuration
variable "subnet_id" {
  description = "ID of the subnet where VM will be deployed"
  type        = string
}

variable "network_interface_name" {
  description = "Name of the network interface. If null, will be auto-generated."
  type        = string
  default     = null
}

variable "private_ip_address_allocation" {
  description = "Private IP address allocation method: Dynamic or Static"
  type        = string
  default     = "Dynamic"
  validation {
    condition     = contains(["Dynamic", "Static"], var.private_ip_address_allocation)
    error_message = "Must be either 'Dynamic' or 'Static'."
  }
}

variable "private_ip_address" {
  description = "Static private IP address (required if allocation is Static)"
  type        = string
  default     = null
}

variable "public_ip_address_id" {
  description = "ID of public IP address to associate with VM (optional)"
  type        = string
  default     = null
}

variable "dns_servers" {
  description = "List of DNS servers for the network interface"
  type        = list(string)
  default     = []
}

variable "enable_ip_forwarding" {
  description = "Enable IP forwarding on the network interface"
  type        = bool
  default     = false
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking (requires supported VM size)"
  type        = bool
  default     = false
}

variable "application_security_group_id" {
  description = "ID of Application Security Group to associate with NIC"
  type        = string
  default     = null
}

# Admin Credentials
variable "admin_username" {
  description = "Administrator username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Administrator password for the VM (required for Windows, optional for Linux)"
  type        = string
  default     = null
  sensitive   = true
}

variable "disable_password_authentication" {
  description = "Disable password authentication for Linux VMs (SSH key only)"
  type        = bool
  default     = true
}

variable "admin_ssh_public_key" {
  description = "SSH public key for Linux VMs when password authentication is disabled"
  type        = string
  default     = null
}

# Availability
variable "availability_set_id" {
  description = "ID of the availability set"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Availability zone number (1, 2, or 3)"
  type        = string
  default     = null
}

# OS Disk Configuration
variable "os_disk_name" {
  description = "Name of the OS disk. If null, will be auto-generated."
  type        = string
  default     = null
}

variable "os_disk_caching" {
  description = "OS disk caching type: None, ReadOnly, or ReadWrite"
  type        = string
  default     = "ReadWrite"
  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "Must be None, ReadOnly, or ReadWrite."
  }
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type: Standard_LRS, Premium_LRS, StandardSSD_LRS, UltraSSD_LRS"
  type        = string
  default     = "Premium_LRS"
  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS", "UltraSSD_LRS", "Premium_ZRS", "StandardSSD_ZRS"], var.os_disk_storage_account_type)
    error_message = "Must be a valid storage account type."
  }
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB (optional, defaults to image size)"
  type        = number
  default     = null
}

variable "os_disk_diff_disk_settings" {
  description = "Ephemeral OS disk settings"
  type = object({
    option    = string
    placement = optional(string)
  })
  default = null
}

# Source Image
variable "source_image_reference" {
  description = "Source image reference for the VM"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "source_image_id" {
  description = "ID of custom image (overrides source_image_reference)"
  type        = string
  default     = null
}

# Plan (for marketplace images)
variable "plan" {
  description = "Plan information for marketplace images"
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

# Identity
variable "identity_type" {
  description = "Type of Managed Identity: SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'"
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "List of User Assigned Identity IDs"
  type        = list(string)
  default     = []
}

# Boot Diagnostics
variable "enable_boot_diagnostics" {
  description = "Enable boot diagnostics"
  type        = bool
  default     = true
}

variable "boot_diagnostics_storage_account_uri" {
  description = "Storage account URI for boot diagnostics (leave null for managed storage)"
  type        = string
  default     = null
}

# Data Disks
variable "data_disks" {
  description = "List of data disks to attach to the VM"
  type = list(object({
    lun                  = number
    disk_size_gb         = number
    storage_account_type = string
    caching              = string
    create_option        = string
  }))
  default = []
}

# Encryption
variable "disk_encryption_set_id" {
  description = "ID of Disk Encryption Set for disk encryption with customer-managed keys"
  type        = string
  default     = null
}

variable "encryption_at_host_enabled" {
  description = "Enable encryption at host (requires VM size support)"
  type        = bool
  default     = false
}

# Additional Capabilities
variable "ultra_ssd_enabled" {
  description = "Enable Ultra SSD support"
  type        = bool
  default     = false
}

# Patch Management
variable "patch_mode" {
  description = "Patch mode: AutomaticByPlatform, AutomaticByOS, Manual, ImageDefault"
  type        = string
  default     = "AutomaticByPlatform"
}

variable "patch_assessment_mode" {
  description = "Patch assessment mode: AutomaticByPlatform or ImageDefault"
  type        = string
  default     = "AutomaticByPlatform"
}

variable "bypass_platform_safety_checks_on_user_schedule_enabled" {
  description = "Bypass platform safety checks on user schedule"
  type        = bool
  default     = false
}

# License
variable "license_type" {
  description = "License type for Azure Hybrid Benefit: Windows_Client, Windows_Server, RHEL_BYOS, SLES_BYOS"
  type        = string
  default     = null
}

# Security
variable "secure_boot_enabled" {
  description = "Enable secure boot (requires trusted launch VM)"
  type        = bool
  default     = false
}

variable "vtpm_enabled" {
  description = "Enable vTPM (requires trusted launch VM)"
  type        = bool
  default     = false
}

# Windows Specific
variable "timezone" {
  description = "Timezone for Windows VM"
  type        = string
  default     = null
}

variable "enable_automatic_updates" {
  description = "Enable automatic updates for Windows VM"
  type        = bool
  default     = true
}

variable "hotpatching_enabled" {
  description = "Enable hotpatching for Windows VM"
  type        = bool
  default     = false
}

# Custom Data
variable "custom_data" {
  description = "Custom data to pass to the VM (cloud-init for Linux, will be base64 encoded)"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data to pass to the VM (will be base64 encoded)"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
