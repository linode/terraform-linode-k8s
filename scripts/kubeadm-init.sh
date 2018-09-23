#!/usr/bin/env bash
set -e

NODE_PRIVATE_IP="$1"
NODE_PUBLIC_IP="$1"

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${NODE_PRIVATE_IP} --apiserver-cert-extra-sans=${NODE_PUBLIC_IP} --ignore-preflight-errors=FileExisting-crictl,Service-Docker,FileContent--proc-sys-net-bridge-bridge-nf-call-iptables
