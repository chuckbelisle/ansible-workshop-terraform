variable "rg_name" {
  type        = string
  description = "Resource group name for the Ansible controller."
}

variable "location" {
  type        = string
  description = "Location for the Ansible controller."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the Ansible controller NIC will be attached."
}

variable "admin_username" {
  type        = string
  description = "Admin username for the Ansible controller VM."
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for the Ansible controller VM."
}

variable "vm_size" {
  type        = string
  description = "Size of the Ansible controller VM."
}

resource "azurerm_public_ip" "ansible" {
  name                = "pip-ansible-controller"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "ansible" {
  name                = "nic-ansible-controller"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ansible.id
  }
}

resource "azurerm_linux_virtual_machine" "ansible" {
  name                = "vm-ansible-controller"
  location            = var.location
  resource_group_name = var.rg_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.ansible.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "osdisk-ansible-controller"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = filebase64("${path.module}/cloud-init-ansible.yaml")
}
