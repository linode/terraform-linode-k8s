#!/usr/bin/env bash
set -e

for mod in ip_vs_sh ip_vs ip_vs_rr ip_vs_wrr nf_conntrack_ipv4; do echo $mod | sudo tee /etc/modules-load.d/$mod.conf; done

# Enable the update-engine, but disable the locksmith which it requires
sudo systemctl unmask update-engine.service || true
sudo systemctl start update-engine.service || true
sudo systemctl stop locksmith.service || true
sudo systemctl mask locksmith.service || true
