#!/bin/bash
set -euo pipefail

PACKAGE=hsflowd

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./host-sflow
GIT=$(cat ./Jenkinsfile | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
COMMIT=$(cat ./Jenkinsfile | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
BUILD=$(cat ./Jenkinsfile | grep 'buildCmd' | sed -nE "s/^.*?'buildCmd': '(.*)'.*$/\1/p")
git clone $GIT
cd ./host-sflow
git checkout $COMMIT
eval $BUILD

#cd ..
#./build.sh

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/vyos-build/packages/$PACKAGE/host-sflow/*.deb "${DEBDIR}${PACKAGE}"