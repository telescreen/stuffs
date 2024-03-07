image = {
  id = "jammy-server-cloudimg-amd64"
  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  source = "../jammy-server-cloudimg-amd64.img"
}

servers = [{
  name = "mon"
  count = 3
  cpu = 2
  memory = 2048
  disk_count = 0
  disk_size = 8589934592
},
{
  name = "osd"
  count = 3
  cpu = 2
  memory = 2048
  disk_count = 1
  disk_size = 8589934592
}]

storage_pool = "default"
