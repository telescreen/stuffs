networks = []
servers = [{
    count = 1
    name = "landscape-server"
    image_id = "864fd0bd-92d5-4210-979e-d49e4f788819"
    flavor = "staging-cpu4-ram8-disk20"
    networks = ["net_stg-reproducer-telescreen-pse"]
    floatingip_net = ""
    key_name = "lpkey"
    root_volume_size = 30
    volume_count = 0
    volume_size = 10
    user_data_file = "../cloudinit_templates/landscape.yaml"
  },
]

