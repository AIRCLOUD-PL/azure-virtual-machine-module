/**
 * Security configurations for Virtual Machine
 * 
 * Implements defense-in-depth security controls
 */

# Azure Monitor Agent Extension (Linux)
resource "azurerm_virtual_machine_extension" "azure_monitor_agent_linux" {
  count = var.enable_monitoring && var.os_type == "Linux" ? 1 : 0

  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.main[0].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.25"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  settings = jsonencode({
    workspaceId = var.log_analytics_workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = var.log_analytics_workspace_key
  })

  tags = local.tags
}

# Azure Monitor Agent Extension (Windows)
resource "azurerm_virtual_machine_extension" "azure_monitor_agent_windows" {
  count = var.enable_monitoring && var.os_type == "Windows" ? 1 : 0

  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.main[0].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.14"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  settings = jsonencode({
    workspaceId = var.log_analytics_workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = var.log_analytics_workspace_key
  })

  tags = local.tags
}

# Dependency Agent Extension (Linux)
resource "azurerm_virtual_machine_extension" "dependency_agent_linux" {
  count = var.enable_monitoring && var.enable_dependency_agent && var.os_type == "Linux" ? 1 : 0

  name                       = "DependencyAgentLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.main[0].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true

  depends_on = [azurerm_virtual_machine_extension.azure_monitor_agent_linux]

  tags = local.tags
}

# Dependency Agent Extension (Windows)
resource "azurerm_virtual_machine_extension" "dependency_agent_windows" {
  count = var.enable_monitoring && var.enable_dependency_agent && var.os_type == "Windows" ? 1 : 0

  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.main[0].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true

  depends_on = [azurerm_virtual_machine_extension.azure_monitor_agent_windows]

  tags = local.tags
}

# Microsoft Antimalware Extension (Windows)
resource "azurerm_virtual_machine_extension" "antimalware" {
  count = var.enable_antimalware && var.os_type == "Windows" ? 1 : 0

  name                       = "IaaSAntimalware"
  virtual_machine_id         = azurerm_windows_virtual_machine.main[0].id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    AntimalwareEnabled        = true
    RealtimeProtectionEnabled = "true"
    ScheduledScanSettings = {
      isEnabled = "true"
      day       = "7"
      time      = "120"
      scanType  = "Quick"
    }
    Exclusions = var.antimalware_exclusions
  })

  tags = local.tags
}

# Network Watcher Extension (Linux)
resource "azurerm_virtual_machine_extension" "network_watcher_linux" {
  count = var.enable_network_watcher && var.os_type == "Linux" ? 1 : 0

  name                       = "NetworkWatcherAgentLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.main[0].id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentLinux"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true

  tags = local.tags
}

# Network Watcher Extension (Windows)
resource "azurerm_virtual_machine_extension" "network_watcher_windows" {
  count = var.enable_network_watcher && var.os_type == "Windows" ? 1 : 0

  name                       = "NetworkWatcherAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.main[0].id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true

  tags = local.tags
}

# Azure Disk Encryption Extension (Linux)
resource "azurerm_virtual_machine_extension" "disk_encryption_linux" {
  count = var.enable_azure_disk_encryption && var.os_type == "Linux" ? 1 : 0

  name                       = "AzureDiskEncryptionForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.main[0].id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryptionForLinux"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    EncryptionOperation = "EnableEncryption"
    KeyVaultURL         = var.key_vault_url
    KeyVaultResourceId  = var.key_vault_id
    KeyEncryptionKeyURL = var.key_encryption_key_url
    KekVaultResourceId  = var.key_vault_id
    VolumeType          = "All"
    EncryptionAlgorithm = "RSA-OAEP"
  })

  tags = local.tags
}

# Azure Disk Encryption Extension (Windows)
resource "azurerm_virtual_machine_extension" "disk_encryption_windows" {
  count = var.enable_azure_disk_encryption && var.os_type == "Windows" ? 1 : 0

  name                       = "AzureDiskEncryption"
  virtual_machine_id         = azurerm_windows_virtual_machine.main[0].id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryption"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    EncryptionOperation = "EnableEncryption"
    KeyVaultURL         = var.key_vault_url
    KeyVaultResourceId  = var.key_vault_id
    KeyEncryptionKeyURL = var.key_encryption_key_url
    KekVaultResourceId  = var.key_vault_id
    VolumeType          = "All"
    EncryptionAlgorithm = "RSA-OAEP"
  })

  tags = local.tags
}

# Custom Script Extension (for post-deployment configuration)
resource "azurerm_virtual_machine_extension" "custom_script" {
  count = var.custom_script_extension != null ? 1 : 0

  name                       = "CustomScriptExtension"
  virtual_machine_id         = var.os_type == "Linux" ? azurerm_linux_virtual_machine.main[0].id : azurerm_windows_virtual_machine.main[0].id
  publisher                  = var.os_type == "Linux" ? "Microsoft.Azure.Extensions" : "Microsoft.Compute"
  type                       = var.os_type == "Linux" ? "CustomScript" : "CustomScriptExtension"
  type_handler_version       = var.os_type == "Linux" ? "2.1" : "1.10"
  auto_upgrade_minor_version = true

  settings = jsonencode(var.custom_script_extension.settings)

  protected_settings = var.custom_script_extension.protected_settings != null ? jsonencode(var.custom_script_extension.protected_settings) : null

  tags = local.tags
}

# Variables for security features
variable "enable_monitoring" {
  description = "Enable Azure Monitor Agent"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for monitoring"
  type        = string
  default     = null
}

variable "log_analytics_workspace_key" {
  description = "Log Analytics Workspace Key"
  type        = string
  default     = null
  sensitive   = true
}

variable "enable_dependency_agent" {
  description = "Enable Dependency Agent for VM Insights"
  type        = bool
  default     = false
}

variable "enable_antimalware" {
  description = "Enable Microsoft Antimalware extension (Windows only)"
  type        = bool
  default     = true
}

variable "antimalware_exclusions" {
  description = "Antimalware exclusions configuration"
  type = object({
    Extensions = optional(string, "")
    Paths      = optional(string, "")
    Processes  = optional(string, "")
  })
  default = {
    Extensions = ""
    Paths      = ""
    Processes  = ""
  }
}

variable "enable_network_watcher" {
  description = "Enable Network Watcher Agent"
  type        = bool
  default     = true
}

variable "enable_azure_disk_encryption" {
  description = "Enable Azure Disk Encryption extension"
  type        = bool
  default     = false
}

variable "key_vault_url" {
  description = "Key Vault URL for disk encryption"
  type        = string
  default     = null
}

variable "key_vault_id" {
  description = "Key Vault resource ID for disk encryption"
  type        = string
  default     = null
}

variable "key_encryption_key_url" {
  description = "Key Encryption Key URL in Key Vault"
  type        = string
  default     = null
}

variable "custom_script_extension" {
  description = "Custom script extension configuration"
  type = object({
    settings           = map(any)
    protected_settings = optional(map(any))
  })
  default = null
}
