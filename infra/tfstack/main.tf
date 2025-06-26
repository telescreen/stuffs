terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
# Not necessary needed if the openstack credentials are sourced before running
provider "openstack" {}


locals {
  servers = flatten([
    for i, sv in var.servers: [
      for j in range(sv.count): {
        name = "${sv.name}${i}${j}"
        image_id = "${sv.image_id}"
        flavor = "${sv.flavor}"
        networks = "${sv.networks}"
        floatingip_net = "${sv.floatingip_net}"
        key_name = "${sv.key_name}"
        user_data_file = "${sv.user_data_file}"
        root_volume_size = "${sv.root_volume_size}"
        volumeid = [ for d in range(sv.volume_count): "${sv.name}${i}${j}_vol${d}" ]
      }
    ]
  ])
  fips = flatten([
    for i, sv in var.servers: [
      for j in range(sv.count): {
         pool = "${sv.floatingip_net}",
         id = i * sv.count + j
      } if sv.floatingip_net != ""
  ]])
  volumes = flatten([
    for i, sv in var.servers: [
      for j in range(sv.count): [
        for d in range(sv.volume_count): { name = "${sv.name}${i}${j}_vol${d}", size = sv.volume_size }
      ]
    ]
  ])
  secgroup_rules = flatten([
    for network in var.networks:
      [ for rule in network.secgroup_rules: merge(rule, { name: network.name })]
  ])
}


# NETWORKS
resource "openstack_networking_network_v2" "networks" {
  for_each       = {for network in var.networks: network.name => network}
  name           = each.key
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnets" {
  for_each   = {for network in var.networks: network.name => network}
  name       = "${each.value.name}_subnet"
  network_id = openstack_networking_network_v2.networks["${each.value.name}"].id
  cidr       = each.value.cidr
  allocation_pool {
    start = each.value.start_ip
    end = each.value.end_ip
  }
  enable_dhcp = each.value.enable_dhcp
  ip_version = 4
}

resource "openstack_networking_secgroup_v2" "secgroup" {
  for_each    = {for network in var.networks: network.name => network}
  name        = "${each.value.name}_secgroup"
  description = "Security group for ${each.value.name} network"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule" {
  count             = length(local.secgroup_rules)
  direction         = local.secgroup_rules[count.index].direction
  ethertype         = "IPv4"
  protocol          = local.secgroup_rules[count.index].protocol
  port_range_min    = local.secgroup_rules[count.index].port_range_min
  port_range_max    = local.secgroup_rules[count.index].port_range_max
  remote_ip_prefix  = local.secgroup_rules[count.index].remote_ip_prefix
  security_group_id = openstack_networking_secgroup_v2.secgroup[local.secgroup_rules[count.index].name].id
}

# VOLUMES
resource "openstack_blockstorage_volume_v3" "volumes" {
  for_each    = tomap({ for volume in local.volumes: volume.name => volume })
  name        = each.value.name
  description = "Data volume laucnched by opentofu"
  size        = each.value.size
}

# SERVERS
resource "openstack_compute_instance_v2" "servers" {
  for_each        = tomap({ for sv in local.servers: sv.name => sv })
  name            = each.value.name
  flavor_name     = each.value.flavor
  key_pair        = each.value.key_name
  #security_groups = ["default", "${var.networks.name}_secgroup"]
  user_data       = file(each.value.user_data_file)

  metadata = {
    origin = "Launched by Opentofu"
  }

  dynamic network {
    for_each = each.value.networks
    content {
      name = network.value
    }
  }

  block_device {
    uuid                  = each.value.image_id
    source_type           = "image"
    volume_size           = each.value.root_volume_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  dynamic block_device {
    for_each = toset(each.value.volumeid)
      content {
        uuid                  = openstack_blockstorage_volume_v3.volumes[block_device.key].id
        boot_index            = -1
        source_type           = "volume"
        destination_type      = "volume"
        delete_on_termination = true
      }
   }

   depends_on = [
     openstack_blockstorage_volume_v3.volumes
   ]
}

# FLOATING IPS
resource "openstack_compute_floatingip_v2" "fips" {
  for_each = { for sv in local.servers: sv.name => sv.floatingip_net if sv.floatingip_net != ""  }
  pool = each.value
}

resource "openstack_compute_floatingip_associate_v2" "fips_asso" {
  for_each = openstack_compute_floatingip_v2.fips
  floating_ip = each.value.address
  instance_id = openstack_compute_instance_v2.servers[each.key].id
}

## OUTPUTS
output "test_servers" {
  value = openstack_compute_instance_v2.servers
  sensitive = true
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl",
    {
        servers = openstack_compute_instance_v2.servers
    }
  )
  filename = "servers.ini"
  file_permission = "0644"
}

