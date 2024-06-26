#!/bin/bash
set -euo pipefail

PACKAGE=hostap

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./wpa
WPAG=$(cat ./Jenkinsfile | awk '/wpa/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
WPAC=$(cat ./Jenkinsfile | awk '/wpa/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $WPAG
cd ./wpa
git checkout $WPAC
cd ..

rm -rf ./$PACKAGE
HAPG=$(cat ./Jenkinsfile | awk '/hostap/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
HAPC=$(cat ./Jenkinsfile | awk '/hostap/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $HAPG
cd ./$PACKAGE
git checkout $HAPC
cd ..

./build.sh

mkdir -p ${DEBDIR}${PACKAGE}
mv ./$PACKAGE/*.deb "${DEBDIR}${PACKAGE}"
mv *.deb "${DEBDIR}${PACKAGE}"