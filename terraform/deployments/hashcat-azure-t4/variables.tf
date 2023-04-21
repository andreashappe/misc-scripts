variable "resource_group_location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "vm_size" {
  type        = string
  default     = "Standard_NC4as_T4_v3"
  description = "Size of the VM to use."
}

variable "username" {
  type        = string
  default     = "adminuser"
  description = "Name of the new admin user."
}

variable "tcp_ports_fw" {
  type        = list(string)
  default     = ["22"]
  description = "Which ports to open at the firewall."
}
