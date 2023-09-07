## Network ##
resource "openstack_networking_network_v2" "test_network" {
  name           = var.network_config.name
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_test_network" {
  name       = "${var.network_config.name}_subnet"
  network_id = openstack_networking_network_v2.test_network.id
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
  subnet_id = openstack_networking_subnet_v2.subnet_test_network.id
}


resource "openstack_networking_secgroup_v2" "test_network_secgroup" {
  name        = "${var.network_config.name}_secgroup"
  description = "a security group for test network"
}

resource "openstack_networking_secgroup_rule_v2" "test_network_secgroup_rule" {
  for_each          = var.secgroup_rules
  direction         = each.value.direction
  ethertype         = "IPv4"
  protocol          = each.key
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  remote_ip_prefix  = each.value.remote_ip_prefix
  security_group_id = openstack_networking_secgroup_v2.test_network_secgroup.id
}

