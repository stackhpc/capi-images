#!/usr/bin/env bash

#####
## This script installs dependencies required to build images with QEMU
## before executing the actual build scripts
#####

set -ex

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

SCRIPT_DIR="$(dirname "$0")"
# Do this instead of executing the script directly as we may need a
# new shell to pick up the new group
exec sg kvm $SCRIPT_DIR/build-ubuntu.sh
