#!/bin/bash

clean_up () {
  # Stop old vms
  lxc stop maas
  lxc stop virtvm
  
  lxc delete virtvm
  lxc delete maas
  
  # Delete old profiles
  lxc profile delete virtvm
}

create_new () {
  # Create new profile
  lxc profile create virtvm
  lxc profile edit virtvm < virtvm-profile.yaml

  # Launch VMs
  lxc launch ubuntu:18.04 -p virtvm maas --config=user.network-config="$(cat maas.yaml)"
  lxc launch ubuntu:18.04 -p virtvm virtvm --config=user.network-config="$(cat virtvm.yaml)"
  lxc config device add maas maas5240 proxy connect=tcp:172.16.224.2:5240 listen=tcp:0.0.0.0:5240
}

if [ $# -eq 0 ]; then
  echo "testenv: Automate test environment creation"
  echo "  -c: cleanup"
  echo "  -n: new"
  exit 1;
elif [ $1 == "new" ]; then
  echo "===Initializing environment==="
  create_new
elif [ $1 == "del" ]; then
  echo "===Cleanup environment==="
  clean_up
fi
