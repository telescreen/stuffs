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
  source         = "jammy-server-cloudimg-amd64.img"
}

locals {
  datadisk_names = flatten([
    for server_id in range(var.server.count): [
      for disk_id, disk in var.server.disks: { 
        name = "${var.server.name}${server_id}_disk${disk_id}.qcow2"
        size = disk.size 
      }
    ]
  ])
}
resource "libvirt_volume" "datadisk" {
  count = length(datadisk_names)
  name = datadisk_names[count.index].name
  size = datadisk_names[count.index].size
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

  #dynamic "disk" {
  #  for_each = var.server.disks
  #  content {
  #    volume_id = libvirt_volume.datadisk[].id
  #  }
  #}
   
  network_interface {
    network_name = "default"
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

output "ips" {
  # show IP, run 'tofu refresh' if not populated
  value = libvirt_domain.server.*.network_interface.0.addresses
}
