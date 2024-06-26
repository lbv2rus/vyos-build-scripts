#!/bin/bash
set -euo pipefail

PACKAGE=keepalived

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./pkg-keepalived
GIT=$(cat ./Jenkinsfile | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
COMMIT=$(cat ./Jenkinsfile | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
BUILD=$(cat ./Jenkinsfile | grep 'buildCmd' | sed -nE "s/^.*?'buildCmd': '(.*)'.*$/\1/p")
git clone $GIT
cd ./pkg-keepalived
git checkout $COMMIT
eval $BUILD

#sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
#../build.py
#cd ..

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/vyos-build/packages/$PACKAGE/pkg-keepalived/*.deb "${DEBDIR}${PACKAGE}"
mv $GITDIR/vyos-build/packages/$PACKAGE/*.deb "${DEBDIR}${PACKAGE}"