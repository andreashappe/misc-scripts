resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = var.rg.location
  resource_group_name = var.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = var.rg.location
  resource_group_name = var.rg.name
}

resource "azurerm_network_security_rule" "incoming_rules" {
    count                      = length(var.tcp_ports_fw)
    name                       = "openPort_TCP_${var.tcp_ports_fw[count.index]}"
    priority                   = 1000 + count.index
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "${var.tcp_ports_fw[count.index]}"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name        = var.rg.name
    network_security_group_name= azurerm_network_security_group.my_terraform_nsg.name
}

resource "azurerm_network_security_rule" "incoming_rules_wg" {
    name                       = "openPort_UDP_wg"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    resource_group_name        = var.rg.name
    network_security_group_name= azurerm_network_security_group.my_terraform_nsg.name
}

# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "myNIC"
  location            = var.rg.location
  resource_group_name = var.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id			  = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "myVM"
  location              = var.rg.location
  resource_group_name   = var.rg.name
  network_interface_ids = [azurerm_network_interface.my_terraform_nic.id]
  size                  = var.vm_size

  priority              = var.priority
  eviction_policy       = var.eviction_policy

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = var.username
  disable_password_authentication = true
  custom_data                     = var.custom_data

  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }
}
