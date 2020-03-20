#!/bin/bash

env_name=alpha
sudo ovs-vsctl add-br alpha-oam
sudo ovs-vsctl add-br $env_name && for VID in 225 226; do sudo ovs-vsctl add-br $env_name-$VID $env_name $VID; done
#sudo ovs-vsctl add-port $env_name eth0
