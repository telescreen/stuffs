resource "openstack_compute_instance_v2" "WindowsServer" {
  count = var.windows_server_count
  name = "Windows Server"
  image_name = var.server_config.win_image
  flavor_name = var.server_config.flavor
  key_pair = var.server_config.key_name
  security_groups = ["${openstack_networking_secgroup_v2.test_network_secgroup.name}"]
  
  network {
     uuid = openstack_networking_network_v2.test_network.id
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

