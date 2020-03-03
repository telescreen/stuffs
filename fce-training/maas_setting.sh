#!/bin/bash

MAAS_USER=telescreen
ENV_NAME=alpha

init() {
  maas $MAAS_USER maas set-config name=maas_name value=$ENV_NAME
  maas $MAAS_USER maas set-config name=upstream_dns value=8.8.8.8
  maas $MAAS_USER maas set-config name=enable_http_proxy value=false
  maas $MAAS_USER maas set-config name=network_discovery value=disabled
  maas $MAAS_USER domain update 0 name=$ENV_NAME.tal
}

create_vlan() {
for VID in 226 227 228 229; do \
maas $MAAS_USER vlans create 0 vid=$VID; \
maas $MAAS_USER subnets create cidr="172.16.$VID.0/24" vlan=`maas $MAAS_USER vlan read 0 $VID | jq ".id"`
done

for VID in 225 226 227 228 229; do maas $MAAS_USER ipranges create type=reserved start_ip=172.16.$VID.1 end_ip=172.16.$VID.50; done

for SPA in oam-space external-space internal-space ceph-access-space ceph-replica-space overlay-space; \
do \
maas $MAAS_USER spaces create name=$SPA; \
done

maas $MAAS_USER vlan update 0 0 space=oam-space
maas $MAAS_USER vlan update 0 225 space=external-space
maas $MAAS_USER vlan update 0 226 space=internal-space
maas $MAAS_USER vlan update 0 227 space=ceph-access-space
maas $MAAS_USER vlan update 0 228 space=ceph-replica-space
maas $MAAS_USER vlan update 0 229 space=overlay-space

maas $MAAS_USER vlan update 0 0 dhcp_on=true primary_rack=`maas $MAAS_USER rack-controllers read | jq ".[] | .system_id" | tr -d '"'`
}

if [ $# -eq 0 ]; then
  echo "maas_setting: setting maas server"
  echo "  init"
  echo "  cvlan"
  exit 1;
elif [ $1 == "init" ]; then
  init
elif [ $1 == "cvlan" ]; then
  create_vlan
fi

