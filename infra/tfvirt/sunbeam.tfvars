image = {
  id = "noble-server-cloudimg-amd64"
  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  source = "/vmimages/noble-server-cloudimg-amd64.img"
}

networks = []

servers = [{
  name = "sunbeam"
  count = 1
  cpu = 8
  memory = 24576
  disk_count = 3
  disk_size = 42949672960
}]

storage_pool = "default"
