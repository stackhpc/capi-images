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
sudo chown root:kvm /dev/kvm

# Check if we need to respawn to pick up the new group
if ! id -nG | grep kvm > /dev/null; then
  exec sg kvm $0
fi

# Work out the Kubernetes version that we are deploying
TAG="${GITHUB_REF##*/}"
# The tag will be of the form {kubernetes version}-{inc}, e.g. 1.21.1-0, 1.22.3-1
# The increment is to be used to trigger builds against a newer Ubuntu for the
# same Kubernetes version
KUBERNETES_VN="${TAG%%-*}"
KUBERNETES_SERIES="${KUBERNETES_VN%%.*}"

cd vendor/kubernetes-sigs/image-builder/images/capi
export PATH="$HOME/.local/bin:$PWD/.local/bin:$PATH"

# Update the Packer configuration for the required Kubernetes version
cat packer/config/kubernetes.json | \
  jq ".kubernetes_series = 'v$KUBERNETES_SERIES'" | \
  jq ".kubernetes_semver = 'v$KUBERNETES_VN'" | \
  jq ".kubernetes_rpm_version = '$KUBERNETES_VN-0'" | \
  jq ".kubernetes_deb_version = '$KUBERNETES_VN-00'"

cat packer/config/kubernetes.json
#make build-qemu-ubuntu-2004
