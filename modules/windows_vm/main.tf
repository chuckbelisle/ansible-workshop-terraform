variable "rg_name" {
  type        = string
  description = "Resource group name for the Windows VMs."
}

variable "location" {
  type        = string
  description = "Location for the Windows VMs."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the Windows VMs."
}

variable "admin_username" {
  type        = string
  description = "Admin username for the Windows VMs."
}

variable "admin_password" {
  type        = string
  description = "Admin password for the Windows VMs."
  sensitive   = true
}

variable "vm_size" {
  type        = string
  description = "Size of the Windows VMs."
}

variable "vm_index" {
  type        = number
  description = "Index of this VM instance (for naming)."
}

resource "azurerm_network_interface" "win" {
  name                = "nic-win-${var.vm_index}"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "win" {
  name                = "vm-win-${var.vm_index}"
  location            = var.location
  resource_group_name = var.rg_name
  size                = var.vm_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.win.id
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = "osdisk-win-${var.vm_index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "winrm" {
  name                 = "winrm-config-${var.vm_index}"
  virtual_machine_id   = azurerm_windows_virtual_machine.win.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
  "commandToExecute": "powershell -ExecutionPolicy Bypass -Command \"winrm quickconfig -q; winrm set winrm/config/service @{AllowUnencrypted=\\\"true\\\"}; winrm set winrm/config/service/auth @{Basic=\\\"true\\\"}; netsh advfirewall firewall add rule name=\\\"WinRM-HTTP-In-TCP\\\" dir=in action=allow protocol=TCP localport=5985\""
}
SETTINGS
}
