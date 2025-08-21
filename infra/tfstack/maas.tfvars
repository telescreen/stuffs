networks = [            
{                          
  name = "maas-manage-network"       
  cidr = "10.150.0.0/16"
  start_ip = "10.150.0.10"
  end_ip = "10.150.0.200"
  secgroup = "maas-secgroup"
  enable_dhcp = false
  secgroup_rules = [
    {                  
      protocol = "tcp"                                                    
      port_range_min = 1                                                  
      port_range_max = 65535                                                                                                                        
      direction = "ingress"
      remote_ip_prefix = "0.0.0.0/0"
    },                     
    {                  
      protocol = "udp"
      port_range_min = 1                                                  
      port_range_max = 65535
      direction = "ingress"
      remote_ip_prefix = "0.0.0.0/0"
    },                        
    {                                                                            
      protocol = "icmp"                 
      port_range_min = 0                                                                                                                            
                        
      port_range_max = 0
      direction = "ingress"
      remote_ip_prefix = "0.0.0.0/0"
    }                
  ]                                                                       
}   
]

servers = [{
    count = 1
    name = "maas"
    image_id = "864fd0bd-92d5-4210-979e-d49e4f788819"
    flavor = "staging-cpu4-ram8-disk20"
    networks = ["net_stg-reproducer-telescreen-pse"]
    floatingip_net = ""
    key_name = "lpkey"
    root_volume_size = 30
    volume_count = 0
    volume_size = 10
    user_data_file = "../cloudinit_templates/maas.yaml"
  },
]

