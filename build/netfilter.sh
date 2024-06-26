#!/bin/bash
set -euo pipefail

PACKAGE=netfilter

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./pkg-libnftnl
NF1G=$(cat ./Jenkinsfile | awk '/pkg-libnftnl/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
NF1C=$(cat ./Jenkinsfile | awk '/pkg-libnftnl/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $NF1G
cd ./pkg-libnftnl
git checkout $NF1C

sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
dpkg-buildpackage -uc -us -tc -b
cd ..

rm -rf ./pkg-nftables
NF2G=$(cat ./Jenkinsfile | awk '/pkg-nftables/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
NF2C=$(cat ./Jenkinsfile | awk '/pkg-nftables/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $NF2G
cd ./pkg-nftables
git checkout $NF2C

dpkg -i ../libnftnl*.deb
sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
../build.py
cd ..

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/vyos-build/packages/$PACKAGE/pkg-libnftnl/*.deb "${DEBDIR}${PACKAGE}"
mv $GITDIR/vyos-build/packages/$PACKAGE/pkg-nftables/*.deb "${DEBDIR}${PACKAGE}"
mv *.deb "${DEBDIR}${PACKAGE}"