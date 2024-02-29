image = {
  id = "jammy-server-cloudimg-amd64"
  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  source = "/home/telescreen/Cases/images/jammy-server-cloudimg-amd64.img"
}
server = {
  name = "server"
  count = 1
  cpu = 1
  memory = 1024
  disk_count = 0
  disk_size = 1073741824
}

storage_pool = "default"
