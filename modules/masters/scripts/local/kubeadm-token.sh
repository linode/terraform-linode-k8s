#!/usr/bin/env bash

set -e

# Extract "host" argument from the input into HOST shell variable
eval "$(python -c 'import sys, json; print("HOST="+json.load(sys.stdin)["host"])')" 2>/dev/null || true

# TODO: pass the ssh key into this command
# Fetch the join command
if [ -z "$HOST" ]; then
  echo "{\"command\":\"\"}"
else
  CMD=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    core@$HOST sudo kubeadm token create --print-join-command | awk '/kubeadm/ && ! /control-plane/ {gsub(/^[ \t]/, "", $0); print $0}' )
  # Produce a JSON object containing the join command
  echo "{\"command\":\"$CMD\"}"
fi
