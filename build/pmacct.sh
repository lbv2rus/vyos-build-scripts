#!/bin/bash
set -euo pipefail

PACKAGE=pmacct

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./$PACKAGE
GIT=$(cat ./Jenkinsfile | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
COMMIT=$(cat ./Jenkinsfile | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
BUILD=$(cat ./Jenkinsfile | grep 'buildCmd' | sed -nE "s/^.*?'buildCmd': '(.*)'.*$/\1/p")

git clone $GIT
cd ./$PACKAGE
git checkout $COMMIT
eval $BUILD

sudo apt install -y git

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/vyos-build/packages/$PACKAGE/$PACKAGE/*.deb "${DEBDIR}${PACKAGE}"
mv $GITDIR/vyos-build/packages/$PACKAGE/*.deb "${DEBDIR}${PACKAGE}"