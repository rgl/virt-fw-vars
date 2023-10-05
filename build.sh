#!/bin/bash
set -euo pipefail

# create and enter the venv.
python3 -m venv .venv
source .venv/bin/activate

# install dependencies.
if [ ! -x /usr/bin/qemu-img ]; then
    sudo apt-get install -y qemu-utils
fi
python3 -m pip install -r requirements.txt

# build the dist.
rm -rf build dist
pyinstaller \
    --add-binary /usr/bin/qemu-img:. \
    .venv/bin/virt-fw-vars

# bundle.
pushd dist/virt-fw-vars
zip -9 -r ../virt-fw-vars.zip .
popd
