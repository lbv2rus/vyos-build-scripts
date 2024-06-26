#!/bin/bash
set -euo pipefail

PACKAGE=pam_tacplus

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./pam_tacplus-debian
PTC=$(cat ./Jenkinsfile | awk '/pam_tacplus-debian/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone https://github.com/kravietz/pam_tacplus-debian
cd ./pam_tacplus-debian
git checkout $PTC
cd ..

rm -rf ./pam_tacplus
PTPC=$(cat ./Jenkinsfile | awk "/pam_tacplus'/,/buildCmd/" | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone https://github.com/kravietz/pam_tacplus
cd ./pam_tacplus
git checkout $PTPC
sed -i '/.*gl_PREREQ_EXPLICIT_BZERO.*/d' configure.ac
cd ..

./build.sh

mkdir -p ${DEBDIR}${PACKAGE}
mv *.deb "${DEBDIR}${PACKAGE}"