#!/bin/bash
set -e

: ${DOMAIN?DOMAIN is Required}

# EXTRA_OPTS="--debug --dry-run"
EXTRA_OPTS=""

helm upgrade mysql incubator/mysqlha --install ${EXTRA_OPTS} --version 0.4.0 \
  --values values/mysqlha.values.yaml

helm upgrade wordpress stable/wordpress --install ${EXTRA_OPTS} --version 3.0.2  \
  --values values/wordpress.values.yaml \
  --set ingress.hosts[0].name="wordpress.${DOMAIN}"

helm upgrade traefik stable/traefik --install ${EXTRA_OPTS} --version 1.46.0 \
  --values values/traefik.values.yaml \
  --set service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"="dashboard.${DOMAIN}"