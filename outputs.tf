output "vm_id" {
  description = "ID of the virtual machine"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.main[0].id : azurerm_windows_virtual_machine.main[0].id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = local.vm_name
}

output "private_ip_address" {
  description = "Private IP address of the VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "public_ip_address" {
  description = "Public IP address of the VM (if assigned)"
  value       = var.public_ip_address_id != null ? azurerm_network_interface.main.ip_configuration[0].public_ip_address_id : null
}

output "network_interface_id" {
  description = "ID of the network interface"
  value       = azurerm_network_interface.main.id
}

output "identity" {
  description = "Managed identity block"
  value = var.os_type == "Linux" ? (
    var.identity_type != null ? azurerm_linux_virtual_machine.main[0].identity : null
    ) : (
    var.identity_type != null ? azurerm_windows_virtual_machine.main[0].identity : null
  )
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity"
  value = var.identity_type != null ? (
    var.os_type == "Linux" ? azurerm_linux_virtual_machine.main[0].identity[0].principal_id : azurerm_windows_virtual_machine.main[0].identity[0].principal_id
  ) : null
}

output "os_disk_id" {
  description = "ID of the OS disk"
  value = var.os_type == "Linux" ? (
    azurerm_linux_virtual_machine.main[0].os_disk[0].name
    ) : (
    azurerm_windows_virtual_machine.main[0].os_disk[0].name
  )
}

output "data_disk_ids" {
  description = "IDs of attached data disks"
  value       = azurerm_managed_disk.data[*].id
}

output "admin_username" {
  description = "Administrator username"
  value       = var.admin_username
}
