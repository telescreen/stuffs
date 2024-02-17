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

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
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

output "servers" {
  value = libvirt_domain.server.*.network_interface.0.addresses.0
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl",
    {
        servers = libvirt_domain.server.*.network_interface.0.addresses.0
    }
  )
  filename = "../ansible/inventory"
  file_permission = "0644"
}
