networks = []
servers = [{
    count = 1
    name = "adserver"
    image_id = "293cbf09-4dfa-4acf-8e59-63b5197f2644"
    flavor = "staging-cpu4-ram8-disk20"
    networks = ["net_stg-reproducer-telescreen-pse"]
    floatingip_net = ""
    key_name = "lpkey"
    root_volume_size = 30
    volume_count = 0
    volume_size = 10
    user_data_file = "../cloudinit_templates/sssd-server.yaml"
  },
  {
    count = 2
    name = "adclient"
    image_id = "293cbf09-4dfa-4acf-8e59-63b5197f2644"
    flavor = "staging-cpu4-ram8-disk20"
    networks = ["net_stg-reproducer-telescreen-pse"]
    floatingip_net = ""
    key_name = "lpkey"
    root_volume_size = 30
    volume_count = 0
    volume_size = 10
    user_data_file = "../cloudinit_templates/sssd-client.yaml"
  },
  {
    count = 1
    name = "adservice"
    image_id = "293cbf09-4dfa-4acf-8e59-63b5197f2644"
    flavor = "staging-cpu2-ram4-disk20"
    networks = ["net_stg-reproducer-telescreen-pse"]
    floatingip_net = ""
    key_name = "lpkey"
    root_volume_size = 30
    volume_count = 0
    volume_size = 10
    user_data_file = "cloud_init.cfg"
  }
]

