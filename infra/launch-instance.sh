#!/bin/bash

### Help ###
###################

Help() {
    # Display Help
    echo "Launch a VM and run template cloud config"
    echo
    echo "Syntax: lauch [options] <server_name>"
    echo "options: "
    echo "    -s | --serie  :  Ubuntu Series: noble(24.04), jammy(22.04), focal(20.04), bionic(18.04)"
    echo "    -c | --cpu    :  CPU Core. Default: 2"
    echo "    -m | --memroy :  Memory. Default: 2048KB"
    echo "    -d | --disk   :  Disk size. Default 40GB"
    echo "    -h | --help   :  Display this help"
    echo
    exit
}

DownloadImage() {
    local BASE_URL=https://cloud-images.ubuntu.com/${UBUNTU_SERIES}/current/${BASE_IMAGE}
    if [ ! -f ${BASE_IMAGE} ]
    then
        wget ${BASE_URL}
    fi
}

error() { echo "$*" >&2; exit 2; }
need_arg() { if [ -z "$OPTARG" ]; then error "No argument for --${OPT} option"; fi }

### Main Program ###
###################
UBUNTU_SERIES=noble
CLOUD_INIT_IMG=cloud_init.img
CPU=2
MEMORY=2048
DISK_SIZE=40  # Gigabytes

while getopts "hc:m:d:s:" OPT; do
    if [ "$OPT" = "-" ]; then
        OPT="${OPTARG%%=*}"
        OPTARG="${OPTARG#"$OPT"}"
        OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
        h|help) 
	    Help;;
        c|cpu)
            need_arg;
            CPU="${OPTARG}";;
        m|memory)
            need_arg;
            MEMORY="${OPTARG}";;
        d|disk)
            need_arg;
            DISK="${OPTARG}";;
        s|serie) 
            need_arg;
            UBUNTU_SERIES="${OPTARG}";;
	*) error "Unknown option -- $OPT";;
    esac
done
shift $((OPTIND-1))
INSTANCE_NAME="$@"
BASE_IMAGE="${UBUNTU_SERIES}-server-cloudimg-amd64.img"

if [ -z "${INSTANCE_NAME}" ]
then
    error "<instance_name> is necessary"
fi

DownloadImage

echo "---- Launching ${INSTANCE_NAME}...Ubuntu: ${UBUNTU_SERIES}. CPU: ${CPU}. Memory: ${MEMORY}. Disk: ${DISK_SIZE} ----"

### DISK ###
if [ ! -f ${INSTANCE_NAME}.qcow2 ]
then
  qemu-img create -f qcow2 -F qcow2 -b ${BASE_IMAGE} ${INSTANCE_NAME}.qcow2 ${DISK_SIZE}G
fi

### CLOUD_INIT ###
# password: possible
rm -f ${CLOUD_INIT_IMG}
rm -f cloud_init.cfg
cat > cloud_init.cfg <<EOF
#cloud-config
timezone: Asia/Tokyo
locale: en_US.utf8
package_update: True
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
  --os-variant ubuntu${UBUNTU_SERIES} \
  --name ${INSTANCE_NAME}  \
  --ram ${MEMORY}        \
  --arch x86_64     \
  --vcpus ${CPU}     \
  --disk path=$PWD/${INSTANCE_NAME}.qcow2    \
  --disk path=$PWD/${CLOUD_INIT_IMG},device=cdrom    \
  --network bridge=virbr0,model=virtio    \
  --serial pty \
  --noautoconsole \
  --import
