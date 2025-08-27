networks = []

servers = [{
    count = 1
    name = "slapd"
    image_id = "fd40a8b0-ec8c-4548-afb5-c28a7865bdf5"
    flavor = "staging-cpu4-ram8-disk20"
    networks = ["net_stg-reproducer-telescreen-pse"]
    floatingip_net = ""
    key_name = "lpkey"
    root_volume_size = 30
    volume_count = 0
    volume_size = 10
    user_data_file = "../cloudinit_templates/openldap.yaml"
  },{
    count = 1
    name = "slapdclient"
    image_id = "fd40a8b0-ec8c-4548-afb5-c28a7865bdf5"
    flavor = "staging-cpu4-ram8-disk20"
    networks = ["net_stg-reproducer-telescreen-pse"]
    floatingip_net = ""
    key_name = "lpkey"
    root_volume_size = 30
    volume_count = 0
    volume_size = 10
    user_data_file = "../cloudinit_templates/openldap-client.yaml"
  },
]

