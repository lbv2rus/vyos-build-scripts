#!/bin/bash
set -euo pipefail

PACKAGE=opennhrp

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./$PACKAGE
GIT=$(cat ./Jenkinsfile | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
COMMIT=$(cat ./Jenkinsfile | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
BUILD=$(cat ./Jenkinsfile | grep 'buildCmd' | sed -nE "s/^.*?'buildCmd': '(.*)'.*$/\1/p")
git clone $GIT $PACKAGE
cd ./$PACKAGE
git checkout $COMMIT
eval $BUILD

#cd ..
#./build.sh

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/vyos-build/packages/$PACKAGE/*.deb "${DEBDIR}${PACKAGE}"