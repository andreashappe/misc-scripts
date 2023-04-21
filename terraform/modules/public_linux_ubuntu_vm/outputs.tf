output "public_ip" {
	value = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
}
