#!/bin/bash

VAULT_FILE="vaultkeys.txt"
export HISTCONTROL=ignorespace  # enable leading space to suppress command history
export VAULT_ADDR='http://localhost:8200'

# Create Key
if [ ! -f "$VAULT_FILE" ]; then
  echo "Initializing 5 keys"
  vault operator init -key-shares=5 -key-threshold=3 > ${VAULT_FILE}
fi

KEY1=grep "Unseal Key 1" ${VAULT_FILE} | awk '{print $4}'
KEY2=grep "Unseal Key 2" ${VAULT_FILE} | awk '{print $4}'
KEY3=grep "Unseal Key 3" ${VAULT_FILE} | awk '{print $4}'
ROOT_TOKEN=grep "Initial Root Token" vaultkeys.txt | awk '{print $4}'

vault operator unseal ${KEY1}
vault operator unseal ${KEY2}
vault operator unseal ${KEY3}

VAULT_TOKEN=${ROOT_TOKEN} vault token create -ttl 10m

