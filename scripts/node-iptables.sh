#!/usr/bin/env bash
set -e

# https://kubernetes.io/docs/setup/independent/install-kubeadm/#worker-node-s
# Kubelet API
iptables --append INPUT --protocol tcp --dport 10250 -j ACCEPT
# NodePort Services
iptables --append INPUT --protocol tcp --match multiport --dport 30000:32767 -j ACCEPT 

# ssh 
iptables --append INPUT --protocol tcp --dport 22 -j ACCEPT

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Default to drop
iptables --policy INPUT DROP

# Persist
iptables-save > /var/lib/iptables/rules-save