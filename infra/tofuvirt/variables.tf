variable "image" {
  type = object({
    id = string
    url= string
  })
  default = {
    id = "jammy-server-cloudimg-amd64"
    url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
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

