# Basic Virtual Machine Example

This example demonstrates the most basic VM deployment with minimal required parameters.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

- Resource Group
- Virtual Network
- Subnet
- Network Interface
- Linux Virtual Machine with System-Assigned Managed Identity

## Configuration

```hcl
module "virtual_machine" {
  source = "../../"

  name                = "vm-example-basic-westeu-001"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.example.name
  environment         = "dev"
  
  vm_size         = "Standard_B2s"
  os_type         = "Linux"
  admin_username  = "azureuser"
  
  subnet_id       = azurerm_subnet.example.id
  
  tags = {
    Example = "Basic"
  }
}
```

## Outputs

- `vm_id` - Resource ID of the virtual machine
- `private_ip_address` - Private IP address assigned to the VM
- `identity_principal_id` - Principal ID of the managed identity
