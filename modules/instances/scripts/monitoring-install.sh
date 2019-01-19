#!/usr/bin/env bash

set -e

# TODO swap these for helm charts

kubectl apply -f /tmp/dashboard-rbac.yaml
kubectl apply -f /tmp/dashboard.yaml

kubectl apply -f /tmp/metrics-server.yaml
