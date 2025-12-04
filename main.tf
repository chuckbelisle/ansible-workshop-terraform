resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.location

  tags = {
    purpose = "ansible-windows-workshop"
  }
}

# Optionally create a new VNet + subnet + NSG when no existing_subnet_id is provided.
resource "azurerm_virtual_network" "this" {
  count               = var.existing_subnet_id == "" ? 1 : 0
  name                = "vnet-ansible-workshop"
  address_space       = var.address_space
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "workshop" {
  count                = var.existing_subnet_id == "" ? 1 : 0
  name                 = "snet-workshop"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [var.subnet_prefix]
}

# NSG allowing WinRM HTTP from within the VNet and SSH to the Ansible controller
resource "azurerm_network_security_group" "this" {
  count               = var.existing_subnet_id == "" ? 1 : 0
  name                = "nsg-ansible-workshop"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  security_rule {
    name                       = "allow-winrm-http-from-vnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh-from-internet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-rdp-from-controller"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.50.1.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "workshop" {
  count                     = var.existing_subnet_id == "" ? 1 : 0
  subnet_id                 = azurerm_subnet.workshop[0].id
  network_security_group_id = azurerm_network_security_group.this[0].id
}

# Determine which subnet ID to use for the workshop hosts:
# - If existing_subnet_id is set, use that.
# - Otherwise, use the subnet created above.
locals {
  workshop_subnet_id = var.existing_subnet_id != "" ? var.existing_subnet_id : azurerm_subnet.workshop[0].id
}

# Ansible controller VM
module "ansible_controller" {
  source = "./modules/ansible_controller"

  rg_name        = azurerm_resource_group.this.name
  location       = azurerm_resource_group.this.location
  subnet_id      = local.workshop_subnet_id
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key
  vm_size        = var.ansible_vm_size
}

# Windows workshop VMs
module "windows_vms" {
  source = "./modules/windows_vm"

  count          = var.windows_vm_count
  rg_name        = azurerm_resource_group.this.name
  location       = azurerm_resource_group.this.location
  subnet_id      = local.workshop_subnet_id
  admin_username = var.admin_username
  admin_password = var.admin_password
  vm_size        = var.windows_vm_size
  vm_index       = count.index
}
