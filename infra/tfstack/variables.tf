variable "provider_router_id" {
  type = string
  default = "5ff7d0f8-3de2-44ba-973a-1c1d0b99e33c"
}

variable "network_config" {
  type = object({
    name = string
    cidr = string
    start_ip = string
    end_ip = string
    secgroup = string
    enable_dhcp = string
  })
  default = {
    name = "test_network"
    cidr = "10.6.0.0/16"
    start_ip = "10.6.0.10"
    end_ip = "10.6.0.200"
    secgroup = "test_network_secgroup"
    enable_dhcp = false
  }
}

variable "secgroup_rules" {
  type = map(object({
    port_range_min = number 
    port_range_max = number 
    direction = string
    remote_ip_prefix = string
  }))
  default = {
    "tcp" = {
      port_range_min = 1
      port_range_max = 65535
      direction = "ingress"
      remote_ip_prefix = "0.0.0.0/0"
    },
    "udp" = {
      port_range_min = 1
      port_range_max = 65535
      direction = "ingress"
      remote_ip_prefix = "0.0.0.0/0"
    },
    "icmp" = {
      port_range_min = 0
      port_range_max = 0
      direction = "ingress"
      remote_ip_prefix = "0.0.0.0/0"
    }
  }
}

variable "server_count" {
  type = number
  default = 1
}

variable "windows_server_count" {
  type = number
  default = 1
}

variable "server_config" {
  type = object({
    name = string
    image = string
    win_image = string
    flavor = string
    key_name = string
  })
  default = {
    name = "server"
    image = "auto-sync/ubuntu-focal-daily-amd64-server-20230110-disk1.img"
    win_image = "Windows2019-virtio"
    flavor = "m1.2xlarge"
    key_name = "testkey"
  }
}
