output "public_ip_address" {
  description = "Public IP address of the Ansible controller VM."
  value       = azurerm_public_ip.ansible.ip_address
}

output "private_ip_address" {
  description = "Private IP address of the Ansible controller VM."
  value       = azurerm_network_interface.ansible.ip_configuration[0].private_ip_address
}
