#!/usr/bin/env bash

#####
## This script builds an Ubuntu-based image for the Kubernetes version
## in the current tag
#####

set -ex

cd vendor/kubernetes-sigs/image-builder/images/capi

export PATH="$HOME/.local/bin:$PWD/.local/bin:$PATH"

make build-qemu-ubuntu-2004
