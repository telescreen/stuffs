networks = []
servers = [{
    count = 1
    name = "test"
    image_id = "f7ed51a5-2dfc-4f81-8b99-7a87ebb820c2"
    flavor = "m1.small"
    networks = ["private"]
    floatingip_net = "ext_net"
    key_name = "testkey"
    root_volume_size = 10
    volume_count = 0
    volume_size = 10
    user_data_file = "cloud_init.cfg"
},{
    count = 2
    name = "cirros"
    image_id = "f52d69bf-39e1-4e8a-b24f-411fae6a6dde"
    flavor = "m1.cirros"
    networks = ["private"]
    floatingip_net = "ext_net"
    key_name = "testkey"
    root_volume_size = 10
    volume_count = 0
    volume_size = 10
    user_data_file = "cloud_init.cfg"
}]

