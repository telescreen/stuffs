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
  disks = flatten([
    for sid in range(var.server.count): [
      for did in range(var.server.disk_count): [ "${var.server.name}${sid}_disk${did}" ]
    ]
  ])
  diskmap = [
    for sid in range(var.server.count): [
      for did in range(var.server.disk_count): { volume_id = "${libvirt_volume.datadisks["${var.server.name}${sid}_disk${did}"].id}" }
    ]
  ]
}

resource "libvirt_network" "networks" {
  for_each = { for index, net in var.networks: net.name => net}
  name = each.value.name
  mode = each.value.mode
  domain = each.value.domain
  addresses = each.value.addresses
  dhcp {
    enabled = true
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

# Download from remote
#resource "libvirt_volume" "image" {
#  name   = var.image.id
#  source = var.image.url
#  format = "qcow2"
#}
#resource "libvirt_volume" "rootdisk" {
#  count          = var.server.count
#  name           = "${var.server.name}${count.index}-root-disk.qcow2"
#  base_volume_id = libvirt_volume.image.id
#}

# From local disk
resource "libvirt_volume" "rootdisk" {
  count          = var.server.count
  name           = "${var.server.name}${count.index}-root-disk.qcow2"
  source         = "${var.image.source}"
  pool           = var.storage_pool
}

resource "libvirt_volume" "datadisks" {
  for_each = toset(local.disks)
  name = "${each.value}.qcow2"
  size = var.server.disk_size
  format = "qcow2"
}

resource "libvirt_domain" "server" {
  count = var.server.count
  name = "${var.server.name}${count.index}"
  memory = "${var.server.memory}"
  vcpu = "${var.server.cpu}"

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  disk {
    volume_id = libvirt_volume.rootdisk[count.index].id
  }

  dynamic "disk" {
    for_each = local.diskmap[count.index]
    content {
      volume_id = disk.value["volume_id"]
    }
  }

  network_interface {
    network_name = "default"
    wait_for_lease = true
    hostname = "${var.server.name}${count.index}"
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

# output
locals {
  servers = merge(
    zipmap(
      libvirt_domain.server.*.name,
      libvirt_domain.server.*.network_interface.0.addresses.0
    )
  )
}

output "servers" {
  value = local.servers
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl",{
    servers = local.servers
  })
  filename = "../ansible/inventory/servers.ini"
  file_permission = "0644"
}
