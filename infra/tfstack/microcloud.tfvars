networks = []
servers = [{
    count = 3
    name = "microcloud"
    image_id = "2b85030e-8ef2-486e-8101-39c5e2a53f81"
    flavor = "staging-cpu8-ram16-disk100"
    networks = ["net_stg-reproducer-telescreen-psd", "net_stg-reproducer-telescreen-psd-extra"]
    floatingip_net = ""
    key_name = "lpkey"
    root_volume_size = 30
    volume_count = 1
    volume_size = 50
    user_data_file = "../cloudinit_templates/microcloud.yaml"
  },
]

