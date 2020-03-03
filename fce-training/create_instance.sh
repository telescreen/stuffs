#!/bin/bash

# Variable that need to set before running this script
MAAS_USER=telescreen
NET=alpha
SSH_USER=telescreen
MAAS_SERVER="172.16.224.3"

# Default values for argument variables
TEMPLATE_NAME="node"
NODE_NUM=1
CPU=1
MEM=1024
OS="ubuntu18.04"
NUMBER_DATA_DISK=0
DATA_DISK_SIZE=10G

while getopts ":t:n:c:m:d:s:" opt; do
  case ${opt} in
    t) TEMPLATE_NAME="$OPTARG"
    ;;
    n) NODE_NUM="$OPTARG"
    ;;
    c) CPU="$OPTARG"
    ;;
    m) MEM="$OPTARG"
    ;;
    d) NUMBER_DATA_DISK="$OPTARG"
    ;;
    s) DATA_DISK_SIZE="$OPTARG"
    ;;
    \?) echo "create_instance.sh -t TEMPLATE_NAME -n NUMBER_OF_NODE -c CPU_CORE -m MEMORY -d NUMBER_DATADISK -s DATA_DISK_SIZE"
	echo "Default value: "
	echo "  TEMPLATE_NAME = node"
	echo "  NUMBER_OF_NODE = 1"
	echo "  CPU_CORE = 1"
	echo "  MEMORY = 1024"
	echo "  NUMBER_DATA_DISK = 0"
	echo "  DATA_DISK_SIZE = 10G"
	exit 1;
    ;;
    esac
done

for ((NODEID=0; NODEID < $NODE_NUM; NODEID++)); do

# Add data disks	
for ((DD = 0; DD < $NUMBER_DATA_DISK; DD++)); do
  qemu-img create -f qcow2 /vms/${TEMPLATE_NAME}${NODEID}-data${DD}.qcow2 $DATA_DISK_SIZE;
done

MAC_ADDR=`date | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/'`

# Create datadisk
qemu-img create -f qcow2 /vms/${TEMPLATE_NAME}${NODEID}-root.qcow2 15G

# Create Instance
virt-install \
--connect=qemu:///system \
--boot network,hd,menu=on \
--name ${TEMPLATE_NAME}${NODEID} \
--ram ${MEM} \
--vcpus=${CPU} \
--cpu host-model \
--os-variant ${OS} \
--controller=scsi,model=virtio-scsi \
--disk path=/vms/${TEMPLATE_NAME}${NODEID}-root.qcow2,bus=virtio \
$(for ((DD = 0; DD < $NUMBER_DATA_DISK; DD++)); do echo --disk path=/vms/${TEMPLATE_NAME}${NODEID}-data${DD}.qcow2,bus=virtio; done) \
--import \
--network type=bridge,source=${NET},virtualport_type=openvswitch,model=virtio,mac=${MAC_ADDR} \
--sound none \
--graphics vnc \
--noautoconsole; \
virsh destroy ${TEMPLATE_NAME}${NODEID}

maas $MAAS_USER machines create hostname=${TEMPLATE_NAME}${NODEID} architecture=amd64/generic mac_addresses=$MAC_ADDR power_type=virsh power_parameters="{\"power_address\": \"qemu+ssh://$SSH_USER@$MAAS_SERVER/system\", \"power_id\": \"${TEMPLATE_NAME}${NODEID}\"}"
done

