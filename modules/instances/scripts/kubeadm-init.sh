#!/usr/bin/env bash
set -e

K8S_CLUSTERNAME="$1"
K8S_VERSION="$2"
NODE_PRIVATE_IP="$3"
NODE_PUBLIC_IP="$4"
K8S_FEATURE_GATES="$5"
POD_NETWORK="10.244.0.0/16"

# Generated with kubeadm config print init-defaults
cat <<EOF > $HOME/kubeadm-config.yml
apiVersion: kubeadm.k8s.io/v1beta1
#bootstrapTokens:
#- groups:
#  - system:bootstrappers:kubeadm:default-node-token
# token: ${TOKEN}
# ttl: 24h0m0s
# usages:
# - signing
# - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${NODE_PUBLIC_IP}
  bindPort: 6443
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: ${NODE_NAME}
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  certSANs:
  - ${NODE_PRIVATE_IP}
  extraArgs:
    cloud-provider: external
    feature-gates: ${K8S_FEATURE_GATES}
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager:
  extraArgs:
    cloud-provider: external
    feature-gates: ""
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: ${K8S_VERSION}
networking:
  dnsDomain: cluster.local
  podSubnet: ${POD_NETWORK}
  serviceSubnet: 10.96.0.0/12
scheduler: {}
EOF

kubeadm init --config $HOME/kubeadm-config.yml
