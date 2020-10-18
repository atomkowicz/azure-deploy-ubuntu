provider "azurerm" {
  features {}
}

locals {
  tags = {
    environment = var.environment
  }
}

# Existing resource group
data "azurerm_resource_group" "main" {
  name = "${var.prefix}-resource-group"
}

# or create resource group

#resource "azurerm_resource_group" "main" {
 # name     = "${var.prefix}-resource-group"
 # location = var.location
#}

# Create a virtual network with a subnet on that network

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/24"]
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Create network security group with rules that allow access to other Vms on the subnet and deny direct access from the internet

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-network-security-group"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "allow-inbound-vnet" {
  name                        = "AllowInboundVnet"
  priority                    = 190
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.0.0.0/16"
  destination_address_prefix  = "10.0.0.0/16"
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "deny-inbound-traffic" {
  name                        = "DenyInboundTraffic"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

# Create network interface

resource "azurerm_network_interface" "main" {
  count               = var.vms_count
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags                = local.tags

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  count                     = var.vms_count
  network_interface_id      = element(azurerm_network_interface.main.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.main.id
}

# Create public IP

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}

# Create a backend address pool and address pool association for the network interface and the load balancer

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = data.azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-backendpool"
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.vms_count
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
  ip_configuration_name   = "${var.prefix}-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# Create load balancer with heath probes

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-load-balancer"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.tags

  frontend_ip_configuration {
    name                 = "${var.prefix}-load-balancer-public-ip"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_lb_probe" "main" {
  resource_group_name = data.azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-load-balancer-health"
  port                = 80
}

resource "azurerm_lb_rule" "main" {
  resource_group_name            = data.azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "${var.prefix}-load-balancer-rule"
  protocol                       = "TCP"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.prefix}-load-balancer-public-ip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  probe_id                       = azurerm_lb_probe.main.id
}

# Create a VM availability set

resource "azurerm_availability_set" "main" {
  name                         = "${var.prefix}-availability-set"
  location                     = data.azurerm_resource_group.main.location
  resource_group_name          = data.azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  tags                         = local.tags
}

# Create a VMs using image deployed with Packer

data "azurerm_image" "image" {
  name                = "azure-deploy-ubuntu-image"
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vms_count
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = data.azurerm_resource_group.main.name
  location                        = data.azurerm_resource_group.main.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids           = [element(azurerm_network_interface.main.*.id, count.index)]
  availability_set_id             = azurerm_availability_set.main.id
  source_image_id                 = data.azurerm_image.image.id
  tags                            = local.tags

  os_disk {
    name                 = "${var.prefix}-osdisk${count.index}"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

# Create managed disks for VMs

resource "azurerm_managed_disk" "main" {
  count                = var.vms_count
  name                 = "${var.prefix}-managed-disk-${count.index}"
  location             = data.azurerm_resource_group.main.location
  resource_group_name  = data.azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
  tags                 = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count              = var.vms_count
  managed_disk_id    = element(azurerm_managed_disk.main.*.id, count.index)
  virtual_machine_id = element(azurerm_linux_virtual_machine.main.*.id, count.index)
  lun                = "0"
  caching            = "ReadWrite"
}
