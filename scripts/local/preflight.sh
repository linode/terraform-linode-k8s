#!/bin/bash
set -e

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
CSI_IMAGE=$2

# substitute Docker images in manifests

sed -e "s|{{ \.Values\.CCMImage }}|${CCM_IMAGE}|g" modules/masters/templates/ccm-linode.yaml.template > modules/masters/manifests/ccm-linode.yaml
sed -e "s|{{ \.Values\.CSIImage }}|${CSI_IMAGE}|g" modules/masters/templates/csi-linode.yaml.template > modules/masters/manifests/csi-linode.yaml

