#!/usr/bin/env bash

#####
## This script builds an Ubuntu-based image for the Kubernetes version
## in the current tag
#####

set -ex

export PATH="$HOME/.local/bin:$PATH"

cd vendor/kubernetes-sigs/image-builder/images/capi
make deps-qemu
