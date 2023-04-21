variable "resource_group_location" {
  type        = string
  default     = "northeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1s"
  description = "Size of the VM to use."
}

variable "username" {
  type        = string
  default     = "adminuser"
  description = "Name of the new admin user."
}

variable "tcp_ports_fw" {
  type        = list(string)
  default     = ["22","80","443","4444","8080"]
  description = "Which ports to open at the firewall."
}

variable "wg_client_public_keys" {
  type        = map
  default = {
    client1 = {
      "ip" = "192.168.123.100/32"
      "public_key" = "xCXZ+prZgnL6dgeSnVfC1NzmFhg7yyAulCtFv4fI8Qc="
    }
  }
}
