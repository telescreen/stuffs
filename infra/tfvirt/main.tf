terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  # Configuration options
  uri = "qemu:///system"
}

locals {
  servers = flatten([
    for i, sv in var.servers: [
      for j in range(sv.count): {
        name = "${sv.name}${i}${j}"
        vcpu = sv.cpu
        memory = sv.memory
        rootvol = "${sv.name}${i}${j}"
        volumeid = [ for d in range(sv.disk_count): "${sv.name}${i}${j}_vol${d}" ]
      }
    ]
  ])
  volumes = flatten([
    for i, sv in var.servers: [
      for j in range(sv.count): [
        for d in range(sv.disk_count): { name = "${sv.name}${i}${j}_vol${d}", size = sv.disk_size }
      ]
    ]
  ])
}

resource "libvirt_network" "networks" {
  for_each = { for index, net in var.networks: net.name => net }
  name = each.value.name
  mode = each.value.mode
  domain = each.value.domain
  addresses = each.value.addresses
  dhcp {
    enabled = each.value.dhcp_enabled
  }
  dns {
    enabled = each.value.dns_enabled
    local_only = each.value.dns_local_only
  }
}


data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
  pool      = var.storage_pool
}

# From local disk
resource "libvirt_volume" "rootvols" {
  for_each       = tomap({ for server in local.servers: server.name => server })
  name           = format("%s.qcow2", each.value.rootvol)
  source         = "${var.image.source}"
  pool           = var.storage_pool
  format         = "qcow2"
}

resource "libvirt_volume" "volumes" {
  for_each = tomap({ for volume in local.volumes: volume.name => volume })
  name   = each.value.name
  pool   = "${var.storage_pool}"
  size   = each.value.size
  format = "qcow2"
}

resource "libvirt_domain" "server" {
 count = length(local.servers)
 name = local.servers[count.index].name
 memory = local.servers[count.index].memory
 vcpu = local.servers[count.index].vcpu

 cloudinit = libvirt_cloudinit_disk.commoninit.id

 disk {
   volume_id = "${libvirt_volume.rootvols["${local.servers[count.index].name}"].id}"
 }

dynamic "disk" {
  for_each = toset(local.servers[count.index].volumeid)
  content {
    volume_id = libvirt_volume.volumes[disk.key].id
  }
}

 network_interface {
   network_name = "default"
   wait_for_lease = true
 }

 dynamic network_interface {
   for_each = var.networks
   content {
     network_id = "${libvirt_network.networks["${network_interface.value.name}"].id}"
   }
 }

 console {
   type = "pty"
   target_port = "0"
 }

 graphics {
   type = "spice"
   listen_type = "address"
   autoport = "true"
 }
}

locals {
  outservers = merge(
    zipmap(
      libvirt_domain.server.*.name,
      libvirt_domain.server.*.network_interface.0.addresses.0
    )
  )
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl",{
    servers = local.outservers
  })
  filename = "../ansible/servers.ini"
  file_permission = "0644"
}
