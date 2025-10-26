# Complete Virtual Machine Example

This example demonstrates a fully-featured enterprise VM deployment with all security features enabled.

## Features Included

- ✅ Encryption at host
- ✅ Secure boot and vTPM
- ✅ System-assigned managed identity
- ✅ Multiple data disks with encryption
- ✅ Azure Monitor Agent
- ✅ Network Watcher
- ✅ Boot diagnostics
- ✅ Accelerated networking
- ✅ Availability zone deployment
- ✅ Azure Policy assignments
- ✅ Comprehensive tagging

## Usage

```bash
# Set your SSH public key path
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)

terraform init
terraform plan
terraform apply
```

## Resources Created

- Resource Group
- Virtual Network with NSG
- Subnet
- Log Analytics Workspace
- Storage Account (for boot diagnostics)
- Network Interface with accelerated networking
- Linux Virtual Machine (Ubuntu 22.04)
- 2x Premium SSD Data Disks
- Azure Monitor Agent Extension
- Network Watcher Extension
- Azure Policy Assignments

## Security Features

### Encryption
- OS and data disks encrypted at rest
- Encryption at host enabled
- HTTPS/TLS for all communications

### Identity & Access
- System-assigned managed identity
- No password authentication (SSH keys only)
- NSG restricting access

### Monitoring & Compliance
- Azure Monitor Agent for metrics/logs
- Network Watcher for network diagnostics
- Azure Policy for compliance enforcement
- Boot diagnostics enabled

## Cost Estimate

Approximate monthly cost (West Europe region):
- VM (Standard_D2s_v3): ~€70
- Premium SSD disks (384 GB total): ~€50
- Log Analytics (5GB included): ~€0-10
- **Total: ~€120-130/month**

*Costs may vary by region and actual usage*
