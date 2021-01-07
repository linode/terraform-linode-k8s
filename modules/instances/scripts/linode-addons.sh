#!/usr/bin/env bash

set -e

LINODE_REGION="$1"
LINODE_TOKEN="$2"

# This function applys manifest and retries once on info errors, specifically
# when a CRD that is used in the manifest is not yet published.
# Workaround for https://github.com/kubernetes/kubectl/issues/845
apply_manifest() {
	local manifest=$1
	local attempts=0

	until [ "$attempts" -gt 1 ]
	do
		out=$(kubectl apply -f $manifest 2>&1 >/dev/null; echo $?)
		ret=$(echo $out | tail -n1)

		attempts=$((attempts+1))
		if [[ $ret -eq 0 ]]; then
			echo "successfully applied manifest: $manifest"
			return 0
		elif [[ ( "$out" =~ "no matches for kind" ) && ( "$attempts" -lt 2 ) ]]; then
			echo "applying $manifest failed because a CRD was not yet published."
			echo "retrying in 2s..."
			sleep 2
			continue
		else
			echo "failed to apply manifest: $manifest"
			echo "exit code: $ret"
			echo "output: $out"
			return 1
		fi
	done
}

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
; do apply_manifest /root/init/${yaml}; done

rm /root/init/linode-token.yaml
