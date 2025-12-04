variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "canadacentral"
}

variable "rg_name" {
  description = "Name of the resource group for this Ansible workshop environment."
  type        = string
}

variable "windows_vm_count" {
  description = "Number of Windows VMs to create for the workshop (per environment)."
  type        = number
  default     = 3
}

variable "windows_vm_size" {
  description = "Size of the Windows workshop VMs."
  type        = string
  default     = "Standard_B2ms"
}

variable "ansible_vm_size" {
  description = "Size of the Ansible controller VM."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for both the Windows VMs and Ansible controller."
  type        = string
  default     = "labadmin"
}

variable "admin_password" {
  description = "Admin password for Windows VMs (must meet Azure complexity requirements)."
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for the Ansible controller VM."
  type        = string
}

variable "address_space" {
  description = "Address space for the virtual network (used only when creating a new VNet)."
  type        = list(string)
  default     = ["10.50.0.0/16"]
}

variable "subnet_prefix" {
  description = "Address prefix for the workshop subnet (used only when creating a new subnet)."
  type        = string
  default     = "10.50.1.0/24"
}

variable "existing_subnet_id" {
  description = "Optional existing subnet ID to deploy into. If set, the VNet/Subnet/NSG in this module will NOT be created."
  type        = string
  default     = ""
}
