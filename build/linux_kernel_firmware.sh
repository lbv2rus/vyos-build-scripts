#!/bin/bash
set -euo pipefail

PACKAGE=linux-kernel

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./linux-firmware
LFWC=$(cat ./Jenkinsfile | awk '/Kernel Firmware/,/userRemoteConfigs/' | awk '/branches:/,/]]/' | sed -nE "s/^.*?name: '(.*)'.*$/\1/p")
git clone https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git -b $LFWC --single-branch

rm -rf ./wireguard-linux-compat
WGC=$(cat ./Jenkinsfile | awk '/Wireguard/,/userRemoteConfigs/' | awk '/branches:/,/]]/' | sed -nE "s/^.*?name: '(.*)'.*$/\1/p")
git clone https://salsa.debian.org/debian/wireguard-linux-compat.git -b $WGC --single-branch

rm -rf ./accel-ppp
ACC=$(cat ./Jenkinsfile | awk '/Accel-PPP/,/userRemoteConfigs/' | awk '/branches:/,/]]/' | sed -nE "s/^.*?name: '(.*)'.*$/\1/p")
git clone https://github.com/accel-ppp/accel-ppp.git --single-branch
cd ./accel-ppp
git checkout $ACC
cd ..

./build-wireguard-modules.sh
./build-accel-ppp.sh
./build-intel-qat.sh
./build-intel-ice.py
./build-driver-realtek-r8152.py
./build-linux-firmware.sh

mkdir -p ${DEBDIR}${PACKAGE}
mv *.deb "${DEBDIR}${PACKAGE}"