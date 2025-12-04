output "ansible_controller_public_ip" {
  description = "Public IP address of the Ansible controller VM."
  value       = module.ansible_controller.public_ip_address
}

output "ansible_controller_private_ip" {
  description = "Private IP address of the Ansible controller VM."
  value       = module.ansible_controller.private_ip_address
}

output "windows_vm_private_ips" {
  description = "Private IP addresses of the Windows workshop VMs."
  value       = [for w in module.windows_vms : w.private_ip_address]
}

output "resource_group_name" {
  description = "Name of the resource group created for this workshop."
  value       = azurerm_resource_group.this.name
}
