#!/bin/bash

# Variable that need to set before running this script
MAAS_USER=telescreen

while getopts ":t:n:" opt; do
  case ${opt} in
    t) TEMPLATE_NAME="$OPTARG"
    ;;
    n) TAG_NAME="$OPTARG"
    ;;
    \?) echo "tag_instance.sh -t TEMPLATE_NAME -n TAG_NAME"
	exit 1;
    ;;
    esac
done

system_ids=$(maas $MAAS_USER machines read | jq --arg name $TEMPLATE_NAME '.[] | select(.hostname | contains($name)) | .system_id' | tr -d '"')
for sid in $system_ids; do
  maas $MAAS_USER tag update-nodes $TAG_NAME add=$sid
done
