#!/bin/bash
set -e

helm upgrade --install --name mysql incubator/mysqlha
helm upgrade --install --name wordpress stable/wordpress
helm upgrade --install --name traefik stable/traefik