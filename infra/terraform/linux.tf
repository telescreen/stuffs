## Servers ##
resource "openstack_compute_instance_v2" "test_server" {
  count = var.server_count
  name = "${var.server_config.name}${count.index}"
  image_name = var.server_config.image
  flavor_name = var.server_config.flavor
  key_pair = var.server_config.key_name
  security_groups = ["${openstack_networking_secgroup_v2.test_network_secgroup.name}"]
  
  network {
     uuid = openstack_networking_network_v2.test_network.id
  }
}

## Floating IP
resource "openstack_networking_floatingip_v2" "floatingip" {
  count = var.server_count
  pool = "ext_net"
}
resource "openstack_compute_floatingip_associate_v2" "floatingip_associate" {
  count = var.server_count
  floating_ip = openstack_networking_floatingip_v2.floatingip[count.index].address
  instance_id = openstack_compute_instance_v2.test_server[count.index].id
}

locals {
  test_servers = merge(
     zipmap(openstack_compute_instance_v2.test_server[*].name,
     openstack_compute_instance_v2.test_server[*].network[0].fixed_ip_v4)
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


