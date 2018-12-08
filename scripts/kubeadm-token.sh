#!/usr/bin/env bash

set -e

# Extract "host" argument from the input into HOST shell variable
eval "$(python -c 'import sys, json; print("HOST="+json.load(sys.stdin)["host"])')"

# TODO: pass the ssh key into this command
# Fetch the join command
CMD=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    core@$HOST sudo kubeadm token create --print-join-command)

# Produce a JSON object containing the join command
echo "{\"command\":$CMD}"
