#!/bin/bash

# Variable that need to set before running this script
MAAS_USER=telescreen

while getopts ":n:" opt; do
  case ${opt} in
   n) NAME="$OPTARG"
    ;;
    \?) echo "deploy_instance.sh -n NAME"
	exit 1;
    ;;
    esac
done

system_id=$(maas $MAAS_USER machines read | jq --arg name $NAME '.[] | select(.hostname | contains($name)) | .system_id' | tr -d '"')
echo "Deploying machine $system_id"
maas $MAAS_USER machine deploy $system_id
