# Ubuntu PXE how to

Ref: https://discourse.ubuntu.com/t/netbooting-the-live-server-installer/14510

1) Define a network with pxeboot

```bash
cat << EOF  > pxe-network.xml
<network connections='1'>
  <name>pxe</name>
  <bridge name='virpxe' stp='on' delay='0'/>
  <ip address='192.168.123.1' netmask='255.255.255.0'>
    <tftp root='/tftp'/>
    <dhcp>
      <range start='192.168.123.2' end='192.168.123.100'/>
      <bootp file='pxelinux.0'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define pxe-network.xml
virsh net-start pxe
```

2) Build tftp

```bash
sudo mkdir /tftp
cd /tftp
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso
sudo mount -r ubuntu-22.04.3-live-server-amd64.iso /mnt
sudo cp /mnt/casper/{vmlinuz, initrd} .
wget http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/current/legacy-images/netboot/pxelinux.0
sudo mkdir pxelinux.0
sudo cat << EOF > pxelinux.0/default
DEFAULT install
LABEL install
 KERNEL vmlinuz
 INITRD initrd
 APPEND root=/dev/ram0 ramdisk_size=1500000 ip=dhcp cloud-config-url=http://192.168.123.1:3003/autoinstall.yaml url=http://192.168.123.1:3003/ubuntu-22.04.3-live-server-amd64.iso autoinstall
EOF
```

3) Run local webserver to server iso/autoinstall.yaml

```bash
python3 -m http.server 3003
```

Poweron a virtual machine. Machine should boot from PXE and auto install following definitions in autoinstall.yaml
