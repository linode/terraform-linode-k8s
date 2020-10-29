#!/usr/bin/env bash

set -e

# TODO swap these for helm charts

kubectl apply -f /root/init/dashboard-rbac.yaml
kubectl apply -f /root/init/dashboard.yaml
kubectl apply -f /root/init/metrics-server.yaml
