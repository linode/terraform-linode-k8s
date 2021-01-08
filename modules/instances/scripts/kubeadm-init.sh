#!/usr/bin/env bash
set -e

K8S_CLUSTERNAME="$1"
K8S_VERSION="$2"
NODE_PRIVATE_IP="$3"
NODE_PUBLIC_IP="$4"
K8S_FEATURE_GATES="$5"
POD_NETWORK="10.244.0.0/16"

kubeadm init \
  --apiserver-advertise-address "$NODE_PUBLIC_IP" \
  --apiserver-cert-extra-sans "$NODE_PRIVATE_IP" \
  --pod-network-cidr "$POD_NETWORK" \
  --kubernetes-version "$K8S_VERSION" \
  --cri-socket /var/run/dockershim.sock \
  --feature-gates "$K8S_FEATURE_GATES"
