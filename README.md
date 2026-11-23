<p align="center">
  <a href="https://aircloud.com.pl"><img src=".github/assets/banner.png" alt="AIRCLOUD: DevOps, cloud and AI engineering" width="100%"></a>
</p>

# azure-virtual-machine-module

**Azure Virtual Machine Terraform module — parameterised, azurerm 4.x, CI-validated.**

[![CI](https://github.com/AIRCLOUD-PL/azure-virtual-machine-module/actions/workflows/ci.yml/badge.svg)](https://github.com/AIRCLOUD-PL/azure-virtual-machine-module/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/AIRCLOUD-PL/azure-virtual-machine-module?sort=semver)](https://github.com/AIRCLOUD-PL/azure-virtual-machine-module/releases)

Enterprise-grade Azure Virtual Machine module with comprehensive security, monitoring, and compliance features.

## Features

✅ **Full Linux and Windows Support** - Complete support for both operating systems  
✅ **Advanced Security** - Encryption at host, Secure Boot, vTPM, Azure Disk Encryption  
✅ **Managed Identity** - System-assigned and user-assigned managed identities  
✅ **Comprehensive Monitoring** - Azure Monitor Agent, Dependency Agent, Network Watcher  
✅ **Data Disk Management** - Multiple data disks with encryption and custom caching  
✅ **High Availability** - Availability Zones and Availability Sets support  
✅ **Azure Policy Integration** - Built-in policy assignments for compliance  
✅ **Naming Conventions** - Microsoft CAF compliant naming patterns  
✅ **Boot Diagnostics** - Enhanced troubleshooting capabilities  
✅ **Patch Management** - Automated patch orchestration  
✅ **Network Security** - Accelerated networking, NSG integration  

## Usage

Pin the module to a release tag:

```hcl
module "virtual_machine" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-virtual-machine-module.git?ref=v1.0.0"

  # required inputs
  admin_username      = "..."
  environment         = "..."
  location            = "..."
  os_type             = "..."
  resource_group_name = "..."
  subnet_id           = "..."
  vm_size             = "..."
}
```

All inputs and outputs are listed in the generated reference below ([Inputs](#inputs), [Outputs](#outputs)). Worked examples live in [`examples/`](examples/).

### Basic Example

```hcl
module "virtual_machine" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-virtual-machine-module.git?ref=v1.0.0"

  name                = "vm-prod-westeu-001"
  location            = "westeurope"
  resource_group_name = "rg-production"
  environment         = "prod"
  
  vm_size         = "Standard_D2s_v3"
  os_type         = "Linux"
  admin_username  = "azureuser"
  
  subnet_id = azurerm_subnet.main.id
  
  # SSH Key Authentication
  disable_password_authentication = true
  admin_ssh_public_key           = file("~/.ssh/id_rsa.pub")
  
  # Managed Identity
  identity_type = "SystemAssigned"
  
  tags = {
    Environment = "Production"
  }
}
```

### Complete Example with All Features

```hcl
module "virtual_machine" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-virtual-machine-module.git?ref=v1.0.0"

  # Naming
  name                = "vm-prod-westeu-001"
  location            = "westeurope"
  resource_group_name = "rg-production"
  environment         = "prod"
  
  # VM Configuration
  vm_size    = "Standard_D4s_v3"
  os_type    = "Linux"
  admin_username = "azureuser"
  
  # Network
  subnet_id                     = azurerm_subnet.main.id
  enable_accelerated_networking = true
  private_ip_address_allocation = "Static"
  private_ip_address            = "10.0.1.10"
  
  # High Availability
  availability_zone = "1"
  
  # Image
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  # Authentication
  disable_password_authentication = true
  admin_ssh_public_key           = var.ssh_public_key
  
  # Storage
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 128
  
  data_disks = [
    {
      lun                  = 0
      disk_size_gb         = 512
      storage_account_type = "Premium_LRS"
      caching              = "ReadWrite"
      create_option        = "Empty"
    }
  ]
  
  # Security
  encryption_at_host_enabled = true
  secure_boot_enabled        = true
  vtpm_enabled               = true
  
  # Identity
  identity_type = "SystemAssigned"
  
  # Monitoring
  enable_monitoring              = true
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.main.workspace_id
  log_analytics_workspace_key    = azurerm_log_analytics_workspace.main.primary_shared_key
  enable_dependency_agent        = true
  enable_network_watcher         = true
  
  # Policies
  enable_policy_assignments = true
  
  # Patch Management
  patch_mode            = "AutomaticByPlatform"
  patch_assessment_mode = "AutomaticByPlatform"
  
  tags = {
    Environment = "Production"
    CostCenter  = "IT"
    Compliance  = "PCI-DSS"
  }
}
```

## Examples

- [Basic](./examples/basic/) - Minimal configuration
- [Complete](./examples/complete/) - Full enterprise features
- [Windows](examples/) - Windows Server VM
- [High Availability](examples/) - Multi-zone deployment

## Security Features

### Encryption
- **Encryption at Host** - Hardware-based encryption
- **Azure Disk Encryption** - BitLocker/dm-crypt encryption
- **Customer-Managed Keys** - Disk Encryption Set support
- **TLS/HTTPS** - Encrypted communications

### Identity & Access
- **Managed Identity** - Azure AD integrated identity
- **SSH Key Authentication** - No password authentication for Linux
- **Just-In-Time Access** - Azure Security Center JIT
- **RBAC Integration** - Role-based access control

### Monitoring & Compliance
- **Azure Monitor** - Metrics, logs, and alerts
- **Network Watcher** - Network diagnostics
- **Boot Diagnostics** - Serial console and screenshots
- **Azure Policy** - Compliance enforcement
- **Microsoft Defender** - Threat protection

### Network Security
- **NSG Integration** - Network security groups
- **Application Security Groups** - Micro-segmentation
- **Azure Firewall** - Stateful firewall
- **Private Endpoints** - Private connectivity

## Naming Convention

The module follows Microsoft Cloud Adoption Framework naming conventions:

```
{workload}-{environment}-{region}-{resource-type}-{instance}
```

Example: `web-prod-westeu-vm-001`

See [naming.tf](./naming.tf) for region and environment abbreviations.

## Testing

### Unit Tests

```bash
cd test
go test -v -timeout 30m
```

### Specific Test

```bash
go test -v -run TestVirtualMachineModuleBasic
```

### All Tests with Coverage

```bash
go test -v -coverprofile=coverage.out
go tool cover -html=coverage.out
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add/update tests
5. Run tests locally
6. Submit a pull request

## License

MIT

## Authors

Platform Engineering Team

## Support

For issues and questions:
- Create an issue in the repository
- Contact: platform-team@company.com

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_application_security_group_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_security_group_association) | resource |
| [azurerm_resource_group_policy_assignment.approved_extensions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.backup_enabled](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.encryption_at_host](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.managed_disks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.secure_boot](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_virtual_machine_data_disk_attachment.data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.antimalware](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.azure_monitor_agent_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.azure_monitor_agent_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.custom_script](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.dependency_agent_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.dependency_agent_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.disk_encryption_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.disk_encryption_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.network_watcher_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.network_watcher_windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Administrator password for the VM (required for Windows, optional for Linux) | `string` | `null` | no |
| <a name="input_admin_ssh_public_key"></a> [admin\_ssh\_public\_key](#input\_admin\_ssh\_public\_key) | SSH public key for Linux VMs when password authentication is disabled | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Administrator username for the VM | `string` | n/a | yes |
| <a name="input_antimalware_exclusions"></a> [antimalware\_exclusions](#input\_antimalware\_exclusions) | Antimalware exclusions configuration | <pre>object({<br/>    Extensions = optional(string, "")<br/>    Paths      = optional(string, "")<br/>    Processes  = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "Extensions": "",<br/>  "Paths": "",<br/>  "Processes": ""<br/>}</pre> | no |
| <a name="input_application_security_group_id"></a> [application\_security\_group\_id](#input\_application\_security\_group\_id) | ID of Application Security Group to associate with NIC | `string` | `null` | no |
| <a name="input_approved_vm_extensions"></a> [approved\_vm\_extensions](#input\_approved\_vm\_extensions) | List of approved VM extension types | `list(string)` | <pre>[<br/>  "MicrosoftMonitoringAgent",<br/>  "OmsAgentForLinux",<br/>  "AzureMonitorLinuxAgent",<br/>  "AzureMonitorWindowsAgent",<br/>  "DependencyAgentLinux",<br/>  "DependencyAgentWindows",<br/>  "AzureDiskEncryptionForLinux",<br/>  "AzureDiskEncryption",<br/>  "CustomScriptExtension",<br/>  "CustomScript"<br/>]</pre> | no |
| <a name="input_availability_set_id"></a> [availability\_set\_id](#input\_availability\_set\_id) | ID of the availability set | `string` | `null` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone number (1, 2, or 3) | `string` | `null` | no |
| <a name="input_boot_diagnostics_storage_account_uri"></a> [boot\_diagnostics\_storage\_account\_uri](#input\_boot\_diagnostics\_storage\_account\_uri) | Storage account URI for boot diagnostics (leave null for managed storage) | `string` | `null` | no |
| <a name="input_bypass_platform_safety_checks_on_user_schedule_enabled"></a> [bypass\_platform\_safety\_checks\_on\_user\_schedule\_enabled](#input\_bypass\_platform\_safety\_checks\_on\_user\_schedule\_enabled) | Bypass platform safety checks on user schedule | `bool` | `false` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Custom data to pass to the VM (cloud-init for Linux, will be base64 encoded) | `string` | `null` | no |
| <a name="input_custom_script_extension"></a> [custom\_script\_extension](#input\_custom\_script\_extension) | Custom script extension configuration | <pre>object({<br/>    settings           = map(any)<br/>    protected_settings = optional(map(any))<br/>  })</pre> | `null` | no |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | List of data disks to attach to the VM | <pre>list(object({<br/>    lun                  = number<br/>    disk_size_gb         = number<br/>    storage_account_type = string<br/>    caching              = string<br/>    create_option        = string<br/>  }))</pre> | `[]` | no |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | Disable password authentication for Linux VMs (SSH key only) | `bool` | `true` | no |
| <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id) | ID of Disk Encryption Set for disk encryption with customer-managed keys | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS servers for the network interface | `list(string)` | `[]` | no |
| <a name="input_enable_accelerated_networking"></a> [enable\_accelerated\_networking](#input\_enable\_accelerated\_networking) | Enable accelerated networking (requires supported VM size) | `bool` | `false` | no |
| <a name="input_enable_antimalware"></a> [enable\_antimalware](#input\_enable\_antimalware) | Enable Microsoft Antimalware extension (Windows only) | `bool` | `true` | no |
| <a name="input_enable_automatic_updates"></a> [enable\_automatic\_updates](#input\_enable\_automatic\_updates) | Enable automatic updates for Windows VM | `bool` | `true` | no |
| <a name="input_enable_azure_disk_encryption"></a> [enable\_azure\_disk\_encryption](#input\_enable\_azure\_disk\_encryption) | Enable Azure Disk Encryption extension | `bool` | `false` | no |
| <a name="input_enable_backup_policy"></a> [enable\_backup\_policy](#input\_enable\_backup\_policy) | Enable backup policy requirement | `bool` | `true` | no |
| <a name="input_enable_boot_diagnostics"></a> [enable\_boot\_diagnostics](#input\_enable\_boot\_diagnostics) | Enable boot diagnostics | `bool` | `true` | no |
| <a name="input_enable_dependency_agent"></a> [enable\_dependency\_agent](#input\_enable\_dependency\_agent) | Enable Dependency Agent for VM Insights | `bool` | `false` | no |
| <a name="input_enable_ip_forwarding"></a> [enable\_ip\_forwarding](#input\_enable\_ip\_forwarding) | Enable IP forwarding on the network interface | `bool` | `false` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable Azure Monitor Agent | `bool` | `true` | no |
| <a name="input_enable_network_watcher"></a> [enable\_network\_watcher](#input\_enable\_network\_watcher) | Enable Network Watcher Agent | `bool` | `true` | no |
| <a name="input_enable_policy_assignments"></a> [enable\_policy\_assignments](#input\_enable\_policy\_assignments) | Enable Azure Policy assignments for this VM | `bool` | `true` | no |
| <a name="input_encryption_at_host_enabled"></a> [encryption\_at\_host\_enabled](#input\_encryption\_at\_host\_enabled) | Enable encryption at host (requires VM size support) | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., prod, dev, test) | `string` | n/a | yes |
| <a name="input_hotpatching_enabled"></a> [hotpatching\_enabled](#input\_hotpatching\_enabled) | Enable hotpatching for Windows VM | `bool` | `false` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of User Assigned Identity IDs | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Type of Managed Identity: SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned' | `string` | `"SystemAssigned"` | no |
| <a name="input_instance_number"></a> [instance\_number](#input\_instance\_number) | Instance number for the VM (used in auto-generated names) | `string` | `"001"` | no |
| <a name="input_key_encryption_key_url"></a> [key\_encryption\_key\_url](#input\_key\_encryption\_key\_url) | Key Encryption Key URL in Key Vault | `string` | `null` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | Key Vault resource ID for disk encryption | `string` | `null` | no |
| <a name="input_key_vault_url"></a> [key\_vault\_url](#input\_key\_vault\_url) | Key Vault URL for disk encryption | `string` | `null` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | License type for Azure Hybrid Benefit: Windows\_Client, Windows\_Server, RHEL\_BYOS, SLES\_BYOS | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace ID for monitoring | `string` | `null` | no |
| <a name="input_log_analytics_workspace_key"></a> [log\_analytics\_workspace\_key](#input\_log\_analytics\_workspace\_key) | Log Analytics Workspace Key | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the virtual machine. If null, will be auto-generated based on naming convention. | `string` | `null` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for resource naming when auto-generating names | `string` | `"vm"` | no |
| <a name="input_network_interface_name"></a> [network\_interface\_name](#input\_network\_interface\_name) | Name of the network interface. If null, will be auto-generated. | `string` | `null` | no |
| <a name="input_os_disk_caching"></a> [os\_disk\_caching](#input\_os\_disk\_caching) | OS disk caching type: None, ReadOnly, or ReadWrite | `string` | `"ReadWrite"` | no |
| <a name="input_os_disk_diff_disk_settings"></a> [os\_disk\_diff\_disk\_settings](#input\_os\_disk\_diff\_disk\_settings) | Ephemeral OS disk settings | <pre>object({<br/>    option    = string<br/>    placement = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_os_disk_name"></a> [os\_disk\_name](#input\_os\_disk\_name) | Name of the OS disk. If null, will be auto-generated. | `string` | `null` | no |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | Size of the OS disk in GB (optional, defaults to image size) | `number` | `null` | no |
| <a name="input_os_disk_storage_account_type"></a> [os\_disk\_storage\_account\_type](#input\_os\_disk\_storage\_account\_type) | OS disk storage account type: Standard\_LRS, Premium\_LRS, StandardSSD\_LRS, UltraSSD\_LRS | `string` | `"Premium_LRS"` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Operating system type: Linux or Windows | `string` | n/a | yes |
| <a name="input_patch_assessment_mode"></a> [patch\_assessment\_mode](#input\_patch\_assessment\_mode) | Patch assessment mode: AutomaticByPlatform or ImageDefault | `string` | `"AutomaticByPlatform"` | no |
| <a name="input_patch_mode"></a> [patch\_mode](#input\_patch\_mode) | Patch mode: AutomaticByPlatform, AutomaticByOS, Manual, ImageDefault | `string` | `"AutomaticByPlatform"` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | Plan information for marketplace images | <pre>object({<br/>    name      = string<br/>    product   = string<br/>    publisher = string<br/>  })</pre> | `null` | no |
| <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address) | Static private IP address (required if allocation is Static) | `string` | `null` | no |
| <a name="input_private_ip_address_allocation"></a> [private\_ip\_address\_allocation](#input\_private\_ip\_address\_allocation) | Private IP address allocation method: Dynamic or Static | `string` | `"Dynamic"` | no |
| <a name="input_public_ip_address_id"></a> [public\_ip\_address\_id](#input\_public\_ip\_address\_id) | ID of public IP address to associate with VM (optional) | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_secure_boot_enabled"></a> [secure\_boot\_enabled](#input\_secure\_boot\_enabled) | Enable secure boot (requires trusted launch VM) | `bool` | `false` | no |
| <a name="input_source_image_id"></a> [source\_image\_id](#input\_source\_image\_id) | ID of custom image (overrides source\_image\_reference) | `string` | `null` | no |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | Source image reference for the VM | <pre>object({<br/>    publisher = string<br/>    offer     = string<br/>    sku       = string<br/>    version   = string<br/>  })</pre> | <pre>{<br/>  "offer": "0001-com-ubuntu-server-jammy",<br/>  "publisher": "Canonical",<br/>  "sku": "22_04-lts-gen2",<br/>  "version": "latest"<br/>}</pre> | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the subnet where VM will be deployed | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Timezone for Windows VM | `string` | `null` | no |
| <a name="input_ultra_ssd_enabled"></a> [ultra\_ssd\_enabled](#input\_ultra\_ssd\_enabled) | Enable Ultra SSD support | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data to pass to the VM (will be base64 encoded) | `string` | `null` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Size of the Virtual Machine (e.g., Standard\_D2s\_v3) | `string` | n/a | yes |
| <a name="input_vtpm_enabled"></a> [vtpm\_enabled](#input\_vtpm\_enabled) | Enable vTPM (requires trusted launch VM) | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | Administrator username |
| <a name="output_data_disk_ids"></a> [data\_disk\_ids](#output\_data\_disk\_ids) | IDs of attached data disks |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity block |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal ID of the system-assigned managed identity |
| <a name="output_naming_convention_example"></a> [naming\_convention\_example](#output\_naming\_convention\_example) | Naming convention example |
| <a name="output_naming_convention_pattern"></a> [naming\_convention\_pattern](#output\_naming\_convention\_pattern) | Naming convention pattern used |
| <a name="output_network_interface_id"></a> [network\_interface\_id](#output\_network\_interface\_id) | ID of the network interface |
| <a name="output_os_disk_id"></a> [os\_disk\_id](#output\_os\_disk\_id) | ID of the OS disk |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the VM |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public IP address of the VM (if assigned) |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | ID of the virtual machine |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | Name of the virtual machine |
<!-- END_TF_DOCS -->

---

## Part of the AIRCLOUD Azure module catalog

Browse all modules with usage snippets in the [module catalog](https://aircloud-pl.github.io/) or on [github.com/AIRCLOUD-PL](https://github.com/AIRCLOUD-PL). Built and maintained by [AIRCLOUD](https://aircloud.com.pl): DevOps, cloud and AI engineering. Need a hand with Azure landing zones or platform engineering? See [aircloud.com.pl/consulting](https://aircloud.com.pl/consulting).
