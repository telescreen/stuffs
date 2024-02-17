variable "networks" {
  type = list(object({
    name = string
    mode = string
    domain = optional(string)
    addresses = list(string)
    dns_enabled = bool
    dns_local_only = bool
  }))
  default = ([{
    name = "private"
    mode = "none"
    domain = null
    addresses = ["192.168.210.0/24"]
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

variable "server" {
  type = object({
    name = string
    count = number
    cpu = number
    memory = number
    disk_count = number
    disk_size = number
  })
  default = {
    name = "ubuntu"
    count = 1
    cpu = 1
    memory = 1024
    disk_count = 0
    disk_size = 1073741824
  }
}

