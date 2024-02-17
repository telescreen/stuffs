# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.52.1"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {}

## Network ##
resource "openstack_networking_network_v2" "network" {
  name           = var.network_config.name
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "${var.network_config.name}_subnet"
  network_id = openstack_networking_network_v2.network.id
  cidr       = var.network_config.cidr
  allocation_pool {
    start = var.network_config.start_ip
    end = var.network_config.end_ip
  }
  enable_dhcp = var.network_config.enable_dhcp
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "add_network_to_provider_router" {
  router_id = var.provider_router_id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}


resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "${var.network_config.name}_secgroup"
  description = "a security group for test network"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule" {
  for_each          = var.secgroup_rules
  direction         = each.value.direction
  ethertype         = "IPv4"
  protocol          = each.key
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  remote_ip_prefix  = each.value.remote_ip_prefix
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

## Servers ##
resource "openstack_compute_instance_v2" "server" {
  count = var.server_count
  name = "${var.server_config.name}${count.index}"
  image_name = var.server_config.image
  flavor_name = var.server_config.flavor
  key_pair = var.server_config.key_name
  security_groups = ["${openstack_networking_secgroup_v2.secgroup.name}"]

  network {
     uuid = openstack_networking_network_v2.network.id
  }
}

## Floating IP ##
resource "openstack_networking_floatingip_v2" "floatingip" {
  count = var.server_count
  pool = "ext_net"
}
resource "openstack_compute_floatingip_associate_v2" "floatingip_associate" {
  count = var.server_count
  floating_ip = openstack_networking_floatingip_v2.floatingip[count.index].address
  instance_id = openstack_compute_instance_v2.server[count.index].id
}


resource "openstack_compute_instance_v2" "WindowsServer" {
  count = var.windows_server_count
  name = "Windows Server"
  image_name = var.server_config.win_image
  flavor_name = var.server_config.flavor
  key_pair = var.server_config.key_name
  security_groups = ["${openstack_networking_secgroup_v2.secgroup.name}"]

  network {
     uuid = openstack_networking_network_v2.network.id
  }
}

## Windows Server FloatingIP
resource "openstack_networking_floatingip_v2" "WindowsServer_floatingip" {
  count = var.windows_server_count
  pool = "ext_net"
}
resource "openstack_compute_floatingip_associate_v2" "WindowsServer_floatingip_associate" {
  count = var.windows_server_count
  floating_ip = openstack_networking_floatingip_v2.WindowsServer_floatingip[count.index].address
  instance_id = openstack_compute_instance_v2.WindowsServer[count.index].id
}

## Output ##
locals {
  test_servers = merge(
     zipmap(openstack_compute_instance_v2.server[*].name,
     openstack_compute_instance_v2.server[*].network[0].fixed_ip_v4)
  )
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl",
    {
        servers = local.test_servers
    }
  )
  filename = "../ansible/inventory"
  file_permission = "0644"
}


