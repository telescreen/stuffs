image = {
  id = "jammy-server-cloudimg-amd64"
  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  source = "../jammy-server-cloudimg-amd64.img"
}

networks = [
{
  name = "maas"
  mode = "nat"
  domain = null
  dhcp_enabled = false
  addresses = ["192.168.21.0/24"]
  dns_enabled = false
  dns_local_only = true
},{
  name = "private"
  mode = "none"
  domain = null
  dhcp_enabled = false
  addresses = ["192.168.31.0/24"]
  dns_enabled = false
  dns_local_only = true
}]

servers = [{
  name = "maas"
  count = 1
  cpu = 2
  memory = 4096 
  disk_count = 0
  disk_size = 8589934592
}]

#storage_pool = "default"
