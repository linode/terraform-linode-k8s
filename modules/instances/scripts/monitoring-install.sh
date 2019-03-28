#!/usr/bin/env bash

set -e

# TODO swap these for helm charts

kubectl apply -f /home/core/init/dashboard-rbac.yaml
kubectl apply -f /home/core/init/dashboard.yaml

kubectl apply -f /home/core/init/metrics-server.yaml
