#!/bin/bash
set -o errexit
set -x
eval $(crc oc-env)
oc login -u kubeadmin -p sPQYK-8HAWV-oiacv-j4sCK https://api.crc.testing:6443
podman login -u `oc whoami` -p `oc whoami --show-token` default-route-openshift-image-registry.apps-crc.testing --tls-verify=false
FILES="/home/ibmsys1/Downloads/6.1.0-TIV-ZAPM-FP00017-cluster/images/*"
for file in $FILES; do
    fn="$(basename "$file")"
    if [[ $fn =~ (.*)\+(.*)\.tar ]] ; then
        imagename=${BASH_REMATCH[1]}
        tag=${BASH_REMATCH[2]}
        podman load -i $file
        podman tag localhost/$imagename:$tag default-route-openshift-image-registry.apps-crc.testing/openshift/$imagename:$tag
        podman push default-route-openshift-image-registry.apps-crc.testing/openshift/$imagename:$tag  --tls-verify=false
    fi
done
