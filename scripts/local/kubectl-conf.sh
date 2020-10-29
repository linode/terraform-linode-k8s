#!/usr/bin/env bash
set -e

WORKSPACE=$1
PUBLIC_IP=$2
PRIVATE_IP=$3
SSH_KEY=$4

scp -i ${SSH_KEY} -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${PUBLIC_IP}:/root/.kube/config admin.conf
sed -e "s/${PRIVATE_IP}/${PUBLIC_IP}/g" admin.conf > ${WORKSPACE}.conf
rm admin.conf
