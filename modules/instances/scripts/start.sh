#!/usr/bin/env bash
set -e

for mod in ip_vs_sh ip_vs ip_vs_rr ip_vs_wrr nf_conntrack_ipv4; do echo $mod | sudo tee /etc/modules-load.d/$mod.conf; done

systemctl stop update-engine
