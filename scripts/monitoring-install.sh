#!/usr/bin/env bash

set -e

# TODO swap these for helm charts
kubectl apply -f /tmp/dashboard-rbac.yaml
kubectl apply -f /tmp/heapster-rbac.yaml
kubectl apply -f /tmp/metrics-server-rbac.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl apply -f /tmp/heapster.yaml;
kubectl apply -f /tmp/metrics-server.yaml;
