#!/usr/bin/env bash

set -e

# Extract "host" argument from the input into HOST shell variable
eval "$(python -c 'import sys, json; print("HOST="+json.load(sys.stdin)["host"])')" 2>/dev/null || true

# Fetch the cert key command
if [ -z "$HOST" ]; then
  echo "{\"command\":\"\"}"
else
  CMD=$(ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    core@$HOST sudo kubeadm init phase upload-certs --experimental-upload-certs| tail -1)
  echo '{"cert-key":"'"${CMD}"'"}'
fi