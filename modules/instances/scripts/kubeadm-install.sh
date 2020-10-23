#!/usr/bin/env bash
set -o nounset -o errexit -o pipefail

K8S_VERSION=$1
CNI_VERSION=$2
CRICTL_VERSION="$3"
HOSTNAME=$4
NODE_IP=$5
K8S_FEATURE_GATES="$6"

get_latest_pkg_revision() {
  local pkg="$1"
  local filter="$2"

  version=`apt list -a $pkg | grep "$filter" | head -1 | awk '{print $2}'`
  echo $version
}

get_docker_version() {
  local semver=(${K8S_VERSION//./ })
  local minor_version=${semver[1]}
  local version=18.09

  if (( $minor_version >= 17 )); then
    version=19.03
  fi
  echo $version
}

# disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# add kubelet configuration
cat << EOF > /etc/default/kubelet
KUBELET_EXTRA_ARGS="--cloud-provider=external --feature-gates=${K8S_FEATURE_GATES}"
EOF

# make sure we have Internet connectivity before proceeding
n=0
until [ $n -ge 120 ]
do
  curl -L "https://github.com" >/dev/null 2>&1 && curl -L "https://storage.googleapis.com" >/dev/null 2>&1 && break
  n=$[$n+1]
  sleep 1
done

mkdir -p /etc/kubernetes/manifests

sudo modprobe br_netfilter

# configure ip tables to see bridge traffic
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# install latest docker daemon
sudo apt-get -y install apt-transport-https curl ca-certificates gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

docker_version=$(get_docker_version)
docker_release=$(get_latest_pkg_revision docker-ce $docker_version)

sudo apt-get update
sudo apt-get install -y \
  docker-ce=$docker_release \
  docker-ce-cli=$docker_release \
  containerd.io

# set up the Docker daemon
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl restart docker

# install CRICTL
mkdir -p /opt/bin
curl -L 2>/dev/null "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz

# add kubernetes apt source
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update

# install CNI
sudo apt-get install -y kubernetes-cni=$(get_latest_pkg_revision kubernetes-cni ${CNI_VERSION:1})
sudo apt-mark hold kubernetes-cni

# install k8s components
comp_ver=$(get_latest_pkg_revision kubelet ${K8S_VERSION:1})
sudo apt-get install -y kubelet=$comp_ver kubeadm=$comp_ver kubectl=$comp_ver
sudo apt-mark hold kubelet kubeadm kubectl

systemctl enable kubelet.service
systemctl start kubelet.service
