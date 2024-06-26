#!/bin/bash
set -euo pipefail

PACKAGE=ddclient

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./ddclient-debian
DDCG=$(cat ./Jenkinsfile | awk '/ddclient-debian/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
DDCC=$(cat ./Jenkinsfile | awk '/ddclient-debian/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $DDCG ddclient-debian
cd ./ddclient-debian
git checkout $DDCC
cd ..


rm -rf ./ddclient-github
DDC2G=$(cat ./Jenkinsfile | awk '/ddclient-github/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
DDC2C=$(cat ./Jenkinsfile | awk '/ddclient-github/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $DDC2G ddclient-github
cd ./ddclient-github
git checkout $DDC2C
cd ..

./build.sh

mkdir -p ${DEBDIR}${PACKAGE}
mv ./ddclient-github/*.deb "${DEBDIR}${PACKAGE}"
mv *.deb "${DEBDIR}${PACKAGE}"