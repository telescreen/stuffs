#!/bin/bash

juju deploy ./k8s.yaml --overlay calico-overlay.yaml --overlay vault-overlay.yaml
