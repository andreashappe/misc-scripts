# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform

resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

module "basic_network" {
	source = "./../../modules/network"
	rg = azurerm_resource_group.rg
}

data "template_file" "user_data" {
  template = file("azure-user-data.sh")
}

module "vm" {
	source = "./../../modules/public_linux_ubuntu_vm"
	rg = azurerm_resource_group.rg
	username = var.username
	vm_size = var.vm_size
	tcp_ports_fw = var.tcp_ports_fw
	subnet_id = module.basic_network.subnet_id
	custom_data = base64encode(data.template_file.user_data.rendered)
}
