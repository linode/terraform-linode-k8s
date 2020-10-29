#!/usr/bin/env bash

set -e

LINODE_REGION="$1"
LINODE_TOKEN="$2"

sed -i -E \
	-e 's/\$\(LINODE_REGION\)/'$LINODE_REGION'/g' \
	-e 's/\$\(LINODE_TOKEN\)/'$LINODE_TOKEN'/g' \
	/root/init/linode-token.yaml

# TODO swap these for helm charts
for yaml in \
	linode-token.yaml \
	ccm-linode.yaml \
	csi-linode.yaml \
	external-dns.yaml \
; do kubectl apply -f /root/init/${yaml}; done

rm /root/init/linode-token.yaml
