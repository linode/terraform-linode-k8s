#!/bin/bash
set -euf -o pipefail

function assertInstalled() {
    for var in "$@"; do
        if ! which $var &> /dev/null; then
            echo "$var not found"
            exit 1
        fi
    done
}

assertInstalled ssh scp sed kubectl python

CCM_IMAGE=$1
CSI_MANIFEST=$2

# substitute Docker images in manifests

sed -e "s|{{ \.Values\.CCMImage }}|${CCM_IMAGE}|g" modules/masters/templates/ccm-linode.yaml.template > modules/masters/manifests/ccm-linode.yaml
curl "${CSI_MANIFEST}" -o modules/masters/manifests/csi-linode.yaml
