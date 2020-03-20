#!/bin/bash

# Variable that need to set before running this script
MAAS_USER=telescreen

while getopts ":t:n:v:" opt; do
  case ${opt} in
    n) NAME="$OPTARG"
    ;;
    t) INF="$OPTARG"
    ;;
    v) VLANID="$OPTARG"
    ;;
    \?) echo "create_interfaces.sh -n NAME -t NAME_OF_PARENT_INTERFACE -v VLANID"
        echo "  Create a new interface to virtual machine NAME. Attach VLANID to PARENT_INTERFACE"
	exit 1;
    ;;
    esac
done

subnet_id=`maas $MAAS_USER subnets read | jq --argjson VLANID "$VLANID" '.[] | select(.vlan.vid==$VLANID) | {name: .name, subnet_id: .id, vlan_id: .vlan.id}' --compact-output`
vlan_id=`echo $subnet_id | jq '.vlan_id'`
subnet_id=`echo $subnet_id | jq '.subnet_id'`

system_id=$(maas telescreen machines read | jq --arg name $NAME '.[] | select(.hostname==$name) | .system_id' | tr -d '"')
parent_interface_id=$(maas $MAAS_USER interfaces read $system_id | jq --arg INF $INF '.[] | select(.name == $INF)| .id')

if [ $VLANID -ne 0 ]; then
  tiface=$(maas $MAAS_USER interfaces create-vlan $system_id vlan=$vlan_id parent=$parent_interface_id | jq '.id')
  maas $MAAS_USER interface link-subnet $system_id $tiface mode=AUTO subnet=$subnet_id
fi
