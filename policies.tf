/**
 * Azure Policies for Virtual Machine Module
 * 
 * Implements enterprise security and compliance policies
 */

# Policy Assignment - Require encryption at host
resource "azurerm_resource_group_policy_assignment" "encryption_at_host" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.vm_name}-encryption-policy"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/fc4d8e41-e223-45ea-9bf8-7d8d1fec8f8e"
  display_name         = "Require Encryption at Host for VM ${local.vm_name}"
  description          = "Ensures VM uses encryption at host"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Policy Assignment - Require Managed Disks
resource "azurerm_resource_group_policy_assignment" "managed_disks" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.vm_name}-managed-disks"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d"
  display_name         = "Audit VMs that do not use managed disks"
  description          = "Ensures all disks are managed disks"
}

# Policy Assignment - Require Backup
resource "azurerm_resource_group_policy_assignment" "backup_enabled" {
  count = var.enable_policy_assignments && var.enable_backup_policy ? 1 : 0

  name                 = "${local.vm_name}-backup-policy"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/013e242c-8828-4970-87b3-ab247555486d"
  display_name         = "Require Azure Backup for Virtual Machines"
  description          = "Ensures VM is protected by Azure Backup"

  parameters = jsonencode({
    effect = {
      value = "AuditIfNotExists"
    }
  })
}

# Policy Assignment - Require Secure Boot
resource "azurerm_resource_group_policy_assignment" "secure_boot" {
  count = var.enable_policy_assignments && (var.secure_boot_enabled || var.vtpm_enabled) ? 1 : 0

  name                 = "${local.vm_name}-secure-boot"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/97566dd7-78ae-4997-8b36-1c7bfe0d8121"
  display_name         = "Audit Virtual Machines without Secure Boot enabled"
  description          = "Ensures VM uses Secure Boot for enhanced security"
}

# Policy Assignment - Approved VM Extensions Only
resource "azurerm_resource_group_policy_assignment" "approved_extensions" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.vm_name}-approved-extensions"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/c0e996f8-39cf-4af9-9f45-83fbde810432"
  display_name         = "Only approved VM extensions should be installed"
  description          = "Restricts VM extensions to approved list"

  parameters = jsonencode({
    approvedExtensions = {
      value = var.approved_vm_extensions
    }
    effect = {
      value = "Audit"
    }
  })
}

# Data source for resource group (for policy assignments)
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Additional variables for policies
variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments for this VM"
  type        = bool
  default     = true
}

variable "enable_backup_policy" {
  description = "Enable backup policy requirement"
  type        = bool
  default     = true
}

variable "approved_vm_extensions" {
  description = "List of approved VM extension types"
  type        = list(string)
  default = [
    "MicrosoftMonitoringAgent",
    "OmsAgentForLinux",
    "AzureMonitorLinuxAgent",
    "AzureMonitorWindowsAgent",
    "DependencyAgentLinux",
    "DependencyAgentWindows",
    "AzureDiskEncryptionForLinux",
    "AzureDiskEncryption",
    "CustomScriptExtension",
    "CustomScript"
  ]
}
