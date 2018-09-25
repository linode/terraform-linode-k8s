#!/usr/bin/env bash
set -e

NODE_PRIVATE_IP="$1"
NODE_PUBLIC_IP="$2"

ERR=1
MAX_TRIES=2
COUNT=0

set +e

# TODO: investigate this, one the first try docker.server and iptables bridge preflight fails
#
# [ERROR Service-Docker]: docker service is not active, please run 'systemctl start docker.service'
# [ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables does not exist
#
# but on the second try the errors are gone, this is most likely something to do with networking or state that is not reset...
# because even after a kubedm reset I can't get the pre flight errors to come back
#
while [  $COUNT -lt $MAX_TRIES ]; do
   kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${NODE_PRIVATE_IP} --apiserver-cert-extra-sans=${NODE_PUBLIC_IP}
   if [ $? -eq 0 ];then
      exit 0
   fi
   echo "Retrying kubeadm init..."
   let COUNT=COUNT+1
done
exit $ERR
