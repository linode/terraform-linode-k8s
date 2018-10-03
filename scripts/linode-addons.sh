#!/usr/bin/env bash

set -e

LINODE_REGION="$1"
LINODE_TOKEN="$2"

sed -i -E \
	-e 's/\$\(LINODE_REGION\)/'$LINODE_REGION'/g' \
	-e 's/\$\(LINODE_TOKEN\)/'$LINODE_TOKEN'/g' \
	/tmp/linode-token.yaml

# TODO permissions? overwrite prevention?
echo '{"token": "'${LINODE_TOKEN}'", "zone": "'${LINODE_REGION}'"}' | sudo tee /etc/kubernetes/cloud-config > /dev/null

# TODO swap these for helm charts
# TODO remove the secrets from /tmp/
for yaml in \
	linode-token.yaml \
	ccm-linode.yaml \
	csi-linode-v0.0.1.yaml \
	external-dns.yaml \
; do kubectl apply -f /tmp/${yaml}; done
