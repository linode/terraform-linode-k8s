#!/usr/bin/env bash

set -e

# Extract "host" argument from the input into HOST shell variable
eval "$(jq -r '@sh "HOST=\(.host)"')"

# TODO: pass the ssh key into this command
# Fetch the join command
CMD=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    core@$HOST sudo kubeadm token create --print-join-command)

# Produce a JSON object containing the join command
jq -n --arg command "$CMD" '{"command":$command}'
