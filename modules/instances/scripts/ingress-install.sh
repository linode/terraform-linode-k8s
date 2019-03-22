#!/usr/bin/env bash

set -e

# TODO swap these for helm charts

kubectl apply -f /tmp/traefik-traefik.yaml
kubectl apply -f /tmp/traefik-ds.yaml
