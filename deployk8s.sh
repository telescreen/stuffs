#!/bin/bash

juju deploy ./k8svault.yaml --overlay calico-overlay.yaml
