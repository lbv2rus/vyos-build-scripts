#!/bin/bash
set -euo pipefail

PACKAGE=pyhumps

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./humps
rm -rf ./$PACKAGE
GIT=$(cat ./Jenkinsfile | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
COMMIT=$(cat ./Jenkinsfile | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
BUILD=$(cat ./Jenkinsfile | grep 'buildCmd' | sed -nE "s/^.*?'buildCmd': '(.*)'.*$/\1/p")

git clone $GIT
cd ./humps
git checkout $COMMIT
eval $BUILD

#cd ./humps
#python setup.py --command-packages=stdeb.command bdist_deb

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/vyos-build/packages/$PACKAGE/humps/deb_dist/*.deb "${DEBDIR}${PACKAGE}"