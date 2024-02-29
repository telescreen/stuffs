#!/bin/bash

if [ $# -eq 0 ];
then
  echo "$0: <server_name>"
  exit 1
fi

INSTANCE_NAME=$1
BASE_IMAGE=jammy-server-cloudimg-amd64.img
CLOUD_INIT_IMG=cloud_init.img

if [ ! -f ${INSTANCE_NAME}.qcow2 ]
then
  qemu-img create -f qcow2 -F qcow2 -b ${BASE_IMAGE} ${INSTANCE_NAME}.qcow2
fi

if [ ! -f ${CLOUD_INIT_IMG} ]
then
  cloud-localds ${CLOUD_INIT_IMG} cloud_init.cfg
fi

virt-install    \
  --name ${INSTANCE_NAME}  \
  --ram 8192        \
  --arch x86_64     \
  --vcpus 4     \
  --os-variant ubuntu22.04     \
  --disk path=$PWD/${INSTANCE_NAME}.qcow2    \
  --disk path=$PWD/${CLOUD_INIT_IMG},device=cdrom    \
  --network bridge=virbr0,model=virtio    \
  --graphics none --serial pty --console pty    \
  --import

