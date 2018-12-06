#!/usr/bin/env bash
set -o nounset -o errexit

NODE_PRIVATE_IP="$1"
HOSTNAME="$2"

sed  -E "/localhost$/s/(localhost)$/\1 $HOSTNAME/" -i /etc/hosts

echo -e "\nAddress=${NODE_PRIVATE_IP}/17" >> /etc/systemd/network/05-eth0.network
systemctl daemon-reload
systemctl restart systemd-networkd

hostnamectl set-hostname ${HOSTNAME} && sudo hostname -F /etc/hostname
