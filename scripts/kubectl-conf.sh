#!/usr/bin/env bash

set -e

WORKSPACE=$1
PUBLIC_IP=$2
PRIVATE_IP=$3

scp -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${PUBLIC_IP}:/etc/kubernetes/admin.conf .
sed -e "s/${PRIVATE_IP}/${PUBLIC_IP}/g" admin.conf > ${WORKSPACE}.conf
rm admin.conf
