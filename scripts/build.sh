#!/usr/bin/env bash

#####
## This script installs dependencies required to build images with QEMU
## before executing the actual build scripts
#####

set -exo pipefail

sudo apt-get update -y
sudo apt-get install -y \
  jq \
  make \
  unzip \
  qemu-kvm \
  libvirt-daemon-system \
  libvirt-clients \
  virtinst cpu-checker \
  libguestfs-tools \
  libosinfo-bin

sudo usermod -a -G kvm $USER
ls -l /dev
sudo chown root:kvm /dev/kvm

# Check if we need to respawn to pick up the new group
if ! id -nG | grep kvm > /dev/null; then
  exec sg kvm $0
fi

cd vendor/kubernetes-sigs/image-builder/images/capi
export PATH="$HOME/.local/bin:$PWD/.local/bin:$PATH"

# Update the Packer configuration for the required Kubernetes version
# The full Kubernetes version will be given as an environment variable
cat packer/config/kubernetes.json | \
  jq -r ".kubernetes_series = \"v${KUBERNETES_VN%.*}\"" | \
  jq -r ".kubernetes_semver = \"v$KUBERNETES_VN\"" | \
  jq -r ".kubernetes_rpm_version = \"$KUBERNETES_VN-0\"" | \
  jq -r ".kubernetes_deb_version = \"$KUBERNETES_VN-00\"" \
  > packer/config/kubernetes.json

make build-qemu-ubuntu-2004
