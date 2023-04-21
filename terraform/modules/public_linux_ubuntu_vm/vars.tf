variable "rg" {
  type        = object({
  	location = string
  	name = string
  })
  description = "Where to place the network."
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

variable "subnet_id" {
	type = string
}

variable "custom_data" {
	type = string
}

variable "priority" {
	type = string
	description = "can optionally be spot"
	default = "Regular"
}

variable "eviction_policy" {
	type = string
	description = "this is only used when priority=spot"
	default = null
}
