#!/bin/bash

# Variable that need to set before running this script
MAAS_USER=telescreen

while getopts ":t:n:" opt; do
  case ${opt} in
    t) NAME="$OPTARG"
    ;;
    n) NUMNODES="$OPTARG"
    ;;
    \?) echo "create_interfaces.sh -t NAME -n NUMBER_OF_NODES"
        echo "  Create a new interface to virtual machine NAME."
	exit 1;
    ;;
    esac
done

subnet_ids=`maas $MAAS_USER subnets read | jq '.[] | {name: .name, subnet_id: .id, vlan_id: .vlan.id, vid: .vlan.vid}' --compact-output`

for ((IDX=0; IDX < $NUMNODES; IDX++ )); do
  system_id=$(maas telescreen machines read | jq --arg name ${NAME}${IDX} '.[] | select(.hostname==$name) | .system_id' | tr -d '"')
  parent_interface_id=$(maas $MAAS_USER interfaces read $system_id | jq '.[] | .id')
  for subnet_id in $subnet_ids; do
    vid=`echo $subnet_id | jq '.vid'`
    vlan_id=`echo $subnet_id | jq '.vlan_id'`
    subnet_id=`echo $subnet_id | jq '.subnet_id'`
    if [ $vid -ne 0 ]; then
      ifaces=$(maas $MAAS_USER interfaces create-vlan $system_id vlan=$vlan_id parent=$parent_interface_id)
      tiface=$(echo $ifaces | grep :$vid | jq '.id')
      if [ $vid -le 230 ]; then
        maas $MAAS_USER interface link-subnet $system_id $tiface mode=AUTO subnet=$subnet_id
      fi
    fi
  done
done
