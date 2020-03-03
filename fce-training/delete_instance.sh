#!/bin/bash

# Variable that need to set before running this script
MAAS_USER=telescreen
DELETE_DISK=false

while getopts ":n:y:" opt; do
  case ${opt} in
    n) NAME="$OPTARG"
    ;;
    y) DELETE_DISK=true
    ;;
   \?) echo "delete_instance.sh -n NAME -d DELETE_DISK?"
	echo "Delete node [NAME] from MaaS and libvirt"
	echo "Arguments: "
	echo "  -n   name of the machine"
	echo "  -y   delete disk or not"
	exit 1;
    ;;
  esac
done

for name in $NAME; do
  # Get the maas's system_id of the machine with name.
  # The system_id will be returned with double quote. Here we use bash string processing
  # to remove the double quote before deleting
  # We delete from maas, then delete from virsh and finally remove disk
  SYSTEM_ID=$(maas ${MAAS_USER} machines read | jq --arg name $name '.[] | select(.hostname==$name) | .system_id')
  maas ${MAAS_USER} machine delete ${SYSTEM_ID//\"}
  virsh shutdown $name
  virsh undefine $name
  if [ "$DELETE_DISK" ]; then
    echo "Deleting disks"
    rm -rf /vms/$name-root.qcow2
    rm -rf /vms/$name-data*.qcow2
  fi
done
