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

assertInstalled ssh scp sed kubectl

CCM_IMAGE=$1
CSI_IMAGE=$2

# substitute Docker images in manifests
rm -rf manifests-tmp
cp -r manifests manifests-tmp

cp manifests-tmp/ccm-linode.yaml manifests-tmp/ccm-linode.yaml.tmp
sed -e "s|{{ \.Values\.CCMImage }}|${CCM_IMAGE}|g" manifests-tmp/ccm-linode.yaml.tmp > manifests-tmp/ccm-linode.yaml

cp manifests-tmp/csi-linode.yaml manifests-tmp/csi-linode.yaml.tmp
sed -e "s|{{ \.Values\.CSIImage }}|${CSI_IMAGE}|g" manifests-tmp/csi-linode.yaml.tmp > manifests-tmp/csi-linode.yaml

