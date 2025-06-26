variable "networks" {
  type = list(object({
    name = string
    cidr = string
    start_ip = string
    end_ip = string
    secgroup = string
    enable_dhcp = string
    secgroup_rules = list(object({
      protocol = string
      port_range_min = number
      port_range_max = number
      direction = string
      remote_ip_prefix = string
    }))
  }))
  default = [{
    name = "telescreen_private_test_network"
    cidr = "10.6.0.0/16"
    start_ip = "10.6.0.10"
    end_ip = "10.6.0.200"
    secgroup = "test_network_secgroup"
    enable_dhcp = false
    secgroup_rules = [
      {
        protocol = "tcp"
        port_range_min = 1
        port_range_max = 65535
        direction = "ingress"
        remote_ip_prefix = "0.0.0.0/0"
      },
      {
        protocol = "udp"
        port_range_min = 1
        port_range_max = 65535
        direction = "ingress"
        remote_ip_prefix = "0.0.0.0/0"
      },
      {
        protocol = "icmp"
        port_range_min = 0
        port_range_max = 0
        direction = "ingress"
        remote_ip_prefix = "0.0.0.0/0"
      }
    ]
  }]
}

variable "servers" {
  type = list(object({
    count = number
    name = string
    image_id = string
    flavor = string
    networks = list(string)
    floatingip_net = string
    key_name = string
    root_volume_size = number
    volume_count = number
    volume_size = number
    user_data_file = string
  }))
  default = [{
    count = 1
    name = "server"
    image_id = "293cbf09-4dfa-4acf-8e59-63b5197f2644"
    flavor = "staging-cpu4-ram8-disk20"
    networks = ["net_stg-reproducer-telescreen-pse", "telescreen_private_test_network"]
    floatingip_net = ""
    key_name = "lpkey"
    root_volume_size = 10
    volume_count = 1
    volume_size = 10
    user_data_file = "cloud_init.cfg"
  }]
}

