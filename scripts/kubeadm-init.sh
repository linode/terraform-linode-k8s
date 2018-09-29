#!/usr/bin/env bash
set -e

NODE_PRIVATE_IP="$1"
NODE_PUBLIC_IP="$2"

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${NODE_PUBLIC_IP} --apiserver-cert-extra-sans=${NODE_PRIVATE_IP}
