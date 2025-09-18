image = {
  id = "noble-server-cloudimg-amd64"
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  source = "/vmdisks/noble-server-cloudimg-amd64.img"
}

networks = [
{
  name = "ovn"
  mode = "nat"
  domain = null
  dhcp_enabled = false
  addresses = ["172.16.21.0/24"]
  dns_enabled = false
  dns_local_only = true
},{
  name = "ceph"
  mode = "none"
  domain = null
  dhcp_enabled = false
  addresses = ["172.16.31.0/24"]
  dns_enabled = false
  dns_local_only = true
}]

servers = [{
  name = "cloud"
  count = 3
  cpu = 2
  memory = 4096 
  networks = ["ovn", "ceph"] 
  disk_count = 2
  disk_size = 17179869184  #17G
  cloudinit_file = "../cloudinit_templates/microcloud.yaml"
}]

storage_pool = "pool"

