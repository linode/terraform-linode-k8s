#!/bin/bash
set -e

helm delete --purge traefik
helm delete --purge wordpress
helm delete --purge mysql