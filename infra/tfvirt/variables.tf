variable "networks" {
  type = list(object({
    name = string
    mode = string
    domain = optional(string)
    dhcp_enabled = bool
    addresses = list(string)
    dns_enabled = bool
    dns_local_only = bool
  }))
  default = ([{
    name = "default"
    mode = "nat"
    domain = null
    dhcp_enabled=false
    addresses = ["192.168.10.0/24"]
    dns_enabled = false
    dns_local_only = true
  }, {
    name = "private"
    mode = "none"
    domain = null
    dhcp_enabled=false
    addresses = ["192.168.21.0/24"]
    dns_enabled = false
    dns_local_only = true
  }])
}

variable "image" {
  type = object({
    id = string
    url= string
    source = string
  })
  default = {
    id = "jammy-server-cloudimg-amd64"
    url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    source = "jammy-server-cloudimg-amd64.img"
  }
  sensitive = true
}

variable "servers" {
  type = list(object({
    name = string
    count = number
    cpu = number
    memory = number
    networks = list(string)
    disk_count = number
    disk_size = number
    cloudinit_file = string
  }))
  default = [{
    name = "ubuntu"
    count = 1
    cpu = 1
    memory = 1024
    networks = ["default"]
    disk_count = 0
    disk_size = 8589934592
    cloudinit_file = "cloud_init.cfg"
  }]
}

variable "storage_pool" {
  type = string
  default = "default"
}
