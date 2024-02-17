image = {
  id = "jammy-server-cloudimg-amd64"
  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  source = "../jammy-server-cloudimg-amd64.img"
}
server = {
  name = "ubuntu"
  count = 2
  cpu = 1
  memory = 1024
  disk_count = 1
  disk_size = 1073741824
}
