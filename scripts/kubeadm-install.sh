#!/usr/bin/env bash

set -e

KUBEADBM_VERSION=$1

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -qq
apt-get install -qy kubeadm=${KUBEADBM_VERSION} kubelet=${KUBEADBM_VERSION} kubectl=${KUBEADBM_VERSION}
apt-mark hold kubeadm kubelet kubectl

