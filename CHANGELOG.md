# Changelog

All notable changes to the Azure Virtual Machine Terraform module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Azure Virtual Machine module

## [1.0.0] - 2025-10-25

### Added
- Full Linux and Windows VM support
- System-assigned and user-assigned managed identities
- Data disk management with encryption
- Azure Monitor Agent integration
- Network Watcher support
- Azure Policy assignments for compliance
- Encryption at host support
- Secure Boot and vTPM support
- Accelerated networking capability
- Availability Zone support
- Boot diagnostics configuration
- Custom script extension support
- Microsoft Defender integration (Windows)
- Dependency Agent support
- Comprehensive tagging support
- Microsoft CAF naming conventions
- Cloud-init support (Linux)
- Automated patch management
- SSH key authentication (Linux)
- NSG and ASG integration
- Multiple example configurations
- Complete Terratest suite
- Full documentation

### Security
- Encryption at rest for all disks
- Encryption at host option
- Azure Disk Encryption support
- Managed Identity preferred over passwords
- No password authentication for Linux by default
- Network isolation capabilities
- Azure Policy enforcement

[Unreleased]: https://github.com/your-org/terraform-azurerm-virtual-machine/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/your-org/terraform-azurerm-virtual-machine/releases/tag/v1.0.0
