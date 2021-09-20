#!/usr/bin/env bash

#####
## This script installs dependencies required to build images with QEMU
## before executing the actual build scripts
#####

set -exo pipefail

sudo apt-get update -y
sudo apt-get install -y \
  make \
  unzip \
  qemu-kvm \
  libvirt-daemon-system \
  libvirt-clients \
  virtinst cpu-checker \
  libguestfs-tools \
  libosinfo-bin

sudo usermod -a -G kvm $USER
sudo chown root:kvm /dev/kvm

# Check if we need to respawn to pick up the new group
if ! id -nG | grep kvm; then
  exec sg kvm $0
fi

cd vendor/kubernetes-sigs/image-builder/images/capi
export PATH="$HOME/.local/bin:$PWD/.local/bin:$PATH"
PACKER_LOG=1 make build-qemu-ubuntu-2004
