# Azure Virtual Machine Terraform Module

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

### Basic Example

```hcl
module "virtual_machine" {
  source = "../../modules/compute/virtual-machine"

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
  source = "../../modules/compute/virtual-machine"

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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.80.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.80.0 |

## Resources

| Name | Type |
|------|------|
| azurerm_network_interface.main | resource |
| azurerm_linux_virtual_machine.main | resource |
| azurerm_windows_virtual_machine.main | resource |
| azurerm_managed_disk.data | resource |
| azurerm_virtual_machine_data_disk_attachment.data | resource |
| azurerm_virtual_machine_extension.azure_monitor_agent_* | resource |
| azurerm_virtual_machine_extension.dependency_agent_* | resource |
| azurerm_virtual_machine_extension.network_watcher_* | resource |
| azurerm_virtual_machine_extension.antimalware | resource |
| azurerm_resource_group_policy_assignment.* | resource |

## Inputs

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| location | Azure region | `string` |
| resource_group_name | Resource group name | `string` |
| environment | Environment name (prod, dev, test) | `string` |
| vm_size | VM size (e.g., Standard_D2s_v3) | `string` |
| os_type | Operating system: Linux or Windows | `string` |
| admin_username | Administrator username | `string` |
| subnet_id | Subnet ID for VM network interface | `string` |

### Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| name | VM name (auto-generated if null) | `string` | `null` |
| naming_prefix | Naming prefix | `string` | `"vm"` |
| instance_number | Instance number | `string` | `"001"` |
| availability_zone | Availability zone (1, 2, or 3) | `string` | `null` |
| identity_type | Managed Identity type | `string` | `"SystemAssigned"` |
| enable_accelerated_networking | Enable accelerated networking | `bool` | `false` |
| os_disk_storage_account_type | OS disk type | `string` | `"Premium_LRS"` |
| os_disk_size_gb | OS disk size in GB | `number` | `null` |
| data_disks | List of data disks | `list(object)` | `[]` |
| encryption_at_host_enabled | Enable encryption at host | `bool` | `false` |
| secure_boot_enabled | Enable secure boot | `bool` | `false` |
| vtpm_enabled | Enable vTPM | `bool` | `false` |
| enable_monitoring | Enable Azure Monitor | `bool` | `true` |
| enable_policy_assignments | Enable Azure Policy | `bool` | `true` |
| tags | Resource tags | `map(string)` | `{}` |

See [variables.tf](./variables.tf) for complete list of inputs.

## Outputs

| Name | Description |
|------|-------------|
| vm_id | Virtual machine resource ID |
| vm_name | Virtual machine name |
| private_ip_address | Private IP address |
| public_ip_address | Public IP address (if assigned) |
| network_interface_id | Network interface ID |
| identity_principal_id | Managed identity principal ID |
| data_disk_ids | Data disk IDs |

## Examples

- [Basic](./examples/basic/) - Minimal configuration
- [Complete](./examples/complete/) - Full enterprise features
- [Windows](./examples/windows/) - Windows Server VM
- [High Availability](./examples/ha/) - Multi-zone deployment

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
