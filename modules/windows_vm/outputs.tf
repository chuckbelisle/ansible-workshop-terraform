output "private_ip_address" {
  description = "Private IP address of this Windows VM."
  value       = azurerm_network_interface.win.ip_configuration[0].private_ip_address
}

output "vm_name" {
  description = "Name of this Windows VM."
  value       = azurerm_windows_virtual_machine.win.name
}
