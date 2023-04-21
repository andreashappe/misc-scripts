output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = module.vm.public_ip
}

output "open_tcp_ports" {
  value = var.tcp_ports_fw
}
