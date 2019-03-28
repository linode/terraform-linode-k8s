#!/usr/bin/env bash

set -e

# TODO swap these for helm charts

kubectl apply -f /home/core/init/update-operator.yaml
