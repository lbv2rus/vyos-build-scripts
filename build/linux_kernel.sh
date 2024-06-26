#!/bin/bash
set -euo pipefail

PACKAGE=linux-kernel

cd $GITDIR/vyos-build/packages/$PACKAGE

# read the required Kernel version
KERNEL_VER=$(cat ../../data/defaults.toml | tomlq -r .kernel_version)

rm -rf ./linux
rm -rf ./linux-${KERNEL_VER}

gpg2 --locate-keys torvalds@kernel.org gregkh@kernel.org
curl -OL https://www.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VER}.tar.xz
curl -OL https://www.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VER}.tar.sign
xz -cd linux-${KERNEL_VER}.tar.xz | gpg2 --verify linux-${KERNEL_VER}.tar.sign -
if [ $? -ne 0 ]; then
    exit 1
fi

# Unpack Kernel source
tar xf linux-${KERNEL_VER}.tar.xz
ln -s linux-${KERNEL_VER} linux

# ... Build Kernel
./build-kernel.sh

mkdir -p ${DEBDIR}${PACKAGE}
mv *.deb "${DEBDIR}${PACKAGE}"
