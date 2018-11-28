#!/usr/bin/env bash
set -e

# https://kubernetes.io/docs/setup/independent/install-kubeadm/#master-node-s
# Kubernetes API server
iptables --append INPUT --protocol tcp --dport 6443 -j ACCEPT
# etcd server client API
iptables --append INPUT --protocol tcp --match multiport --dport 2379:2380 -j ACCEPT
# Kubelet API
iptables --append INPUT --protocol tcp --dport 10250 -j ACCEPT
# kube-scheduler
iptables --append INPUT --protocol tcp --dport 10251 -j ACCEPT
# kube-controller-manager	Self
iptables --append INPUT --protocol tcp --dport 10252 -j ACCEPT

# ssh 
iptables --append INPUT --protocol tcp --dport 22 -j ACCEPT

iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Default to drop
iptables --policy INPUT DROP

# Persist
iptables-save > /var/lib/iptables/rules-save

