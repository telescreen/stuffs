servers = [{
    count = 1
    name = "adserver"
    image_id = "293cbf09-4dfa-4acf-8e59-63b5197f2644"
    flavor = "staging-cpu4-ram8-disk20"
    networks = ["net_stg-reproducer-telescreen-pse"]
    key_name = "lpkey"
    volume_count = 0
    volume_size = 10
    user_data_file = "cloud_init.cfg"
  },
  {
    count = 1
    name = "adclient"
    image_id = "293cbf09-4dfa-4acf-8e59-63b5197f2644"
    flavor = "staging-cpu4-ram8-disk20"
    networks = ["net_stg-reproducer-telescreen-pse"]
    key_name = "lpkey"
    volume_count = 0
    volume_size = 10
    user_data_file = "cloud_init.cfg"
  }
]

