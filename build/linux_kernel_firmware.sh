#!/bin/bash
set -euo pipefail

PACKAGE=linux-kernel

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./linux-firmware
LFWG=$(cat ./Jenkinsfile | awk '/linux-firmware/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
LFWC=$(cat ./Jenkinsfile | awk '/linux-firmware/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $LFWG
cd ./linux-firmware
git checkout $LFWC
cd ..

./build-linux-firmware.sh

rm -rf ./accel-ppp
ACG=$(cat ./Jenkinsfile | awk '/accel-ppp/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
ACC=$(cat ./Jenkinsfile | awk '/accel-ppp/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $ACG
cd ./accel-ppp
git checkout $ACC
cd ..

# XXX: please note that this must be installed after nftable dependencies - otherwise
# APT will remove liblua5.3-dev which breaks the Accel-PPP build
sudo apt remove libeditreadline-dev
sudo apt install -y liblua5.3-dev

./build-accel-ppp.sh


./build-intel-qat.sh
./build-intel-ixgbe.sh
./build-intel-ixgbevf.sh
./build-jool.py

rm -rf ./ovpn-dco
OVPG=$(cat ./Jenkinsfile | awk '/ovpn-dco/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
OVPC=$(cat ./Jenkinsfile | awk '/ovpn-dco/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $OVPG
cd ./ovpn-dco
git checkout $OVPC
cd ..

./build-openvpn-dco.sh

mkdir -p ${DEBDIR}${PACKAGE}
mv *.deb "${DEBDIR}${PACKAGE}"