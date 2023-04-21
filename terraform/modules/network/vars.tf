variable "rg" {
  type        = object({
  	location = string
  	name = string
  })
  description = "Where to place the network."
}

variable "address_space" {
	type = string
	default = "10.0.0.0/16"
}

variable "net_subnet" {
	type = string
	default = "10.0.1.0/24"
}
