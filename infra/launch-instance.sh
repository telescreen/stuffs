#!/bin/bash

if [ $# -eq 0 ];
then
  echo "$0: <server_name>"
  exit 1
fi

INSTANCE_NAME=$1
BASE_IMAGE=jammy-server-cloudimg-amd64.img
CLOUD_INIT_IMG=cloud_init.img

if [ ! -f ${BASE_IMAGE} ]
then
  wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
  qemu-img resize ${BASE_IMAGE} 20G
fi

### DISK ###
if [ ! -f ${INSTANCE_NAME}.qcow2 ]
then
  qemu-img create -f qcow2 -F qcow2 -b ${BASE_IMAGE} ${INSTANCE_NAME}.qcow2
fi

### CLOUD_INIT ###
# password: possible
cat > cloud_init.cfg <<EOF
#cloud-config
timezone: Asia/Tokyo
locale: en_US.utf8
package_upgrade: True
hostname: ${INSTANCE_NAME}
chpasswd:
  expire: False
users:
  - name: ubuntu
    ssh_import_id:
      - gh:telescreen
    lock_passwd: false
    passwd: "\$6\$0SSkAaAjMmpvEAmH\$J.a1O3IhQ5EejvtALUdt9DUEtZ6K9eTq4ICClDAu6ngAeMMrmDK/hSfW3URZ92LjdD4MTnJ/yJmSn1oRwEZox/"
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    uid: 1000

EOF
cloud-localds ${CLOUD_INIT_IMG} cloud_init.cfg

virt-install    \
  --name ${INSTANCE_NAME}  \
  --ram 8192        \
  --arch x86_64     \
  --vcpus 4     \
  --os-variant ubuntu22.04     \
  --disk path=$PWD/${INSTANCE_NAME}.qcow2    \
  --disk path=$PWD/${CLOUD_INIT_IMG},device=cdrom    \
  --network bridge=virbr0,model=virtio    \
  --serial pty \
  --noautoconsole \
  --import

