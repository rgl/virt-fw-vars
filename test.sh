#!/bin/bash
set -euo pipefail

# build test image.
docker build -t virt-fw-vars-test -f Dockerfile.test .
mkdir -p tmp
function virt-fw-vars {
    docker run \
        --rm \
        --volume "$PWD:/host" \
        virt-fw-vars-test \
        "$@"
}

# test.
echo 'Setting the firmware variables...'
virt-fw-vars \
    --input /host/RPI_EFI.fd \
    --output /host/tmp/RPI_EFI.fd \
    --set-json /host/RPI_EFI.vars.json

echo 'Listing the firmware variables...'
virt-fw-vars \
    --input /host/tmp/RPI_EFI.fd \
    --print
