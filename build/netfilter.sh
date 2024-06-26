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
dpkg-buildpackage -uc -us -tc -b
cd ..

rm -rf ./pkg-nftables
NF2G=$(cat ./Jenkinsfile | awk '/pkg-nftables/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
NF2C=$(cat ./Jenkinsfile | awk '/pkg-nftables/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $NF2G
cd ./pkg-nftables
git checkout $NF2C
sudo dpkg -i ../libnftnl*.deb
sed -i "s/debhelper-compat.*/debhelper-compat (= 12),/" debian/control
dpkg-buildpackage -uc -us -tc -b
cd ..

rm -rf ./pkg-libnetfilter-conntrack
NF3G=$(cat ./Jenkinsfile | awk '/pkg-libnetfilter-conntrack/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
NF3C=$(cat ./Jenkinsfile | awk '/pkg-libnetfilter-conntrack/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $NF3G
cd ./pkg-libnetfilter-conntrack
git checkout $NF3C
dpkg-buildpackage -uc -us -tc -b
cd ..

rm -rf ./pkg-conntrack-tools
NF4G=$(cat ./Jenkinsfile | awk '/pkg-conntrack-tools/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
NF4C=$(cat ./Jenkinsfile | awk '/pkg-conntrack-tools/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $NF4G
cd ./pkg-conntrack-tools
git checkout $NF4C
sudo dpkg -i ../libnetfilter*.deb && dpkg-buildpackage -uc -us -tc -b
cd ..

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/vyos-build/packages/$PACKAGE/*.deb "${DEBDIR}${PACKAGE}"