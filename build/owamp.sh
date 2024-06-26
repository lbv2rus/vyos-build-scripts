#!/bin/bash
set -euo pipefail

PACKAGE=owamp

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./$PACKAGE
GIT=$(cat ./Jenkinsfile | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
COMMIT=$(cat ./Jenkinsfile | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
BUILD=$(cat ./Jenkinsfile | grep 'buildCmd' | sed -nE "s/^.*?'buildCmd': '(.*)'.*$/\1/p")
git clone $GIT $PACKAGE
cd ./$PACKAGE
git checkout $COMMIT
cd ..

if id "$PACKAGE" >/dev/null 2>&1; then
    sudo deluser $PACKAGE
fi
sudo useradd $PACKAGE

sudo chown -R $PACKAGE $GITDIR/vyos-build/packages/$PACKAGE
sudo -u $PACKAGE ./build.sh

sudo chown -R root $GITDIR/vyos-build/packages/$PACKAGE
sudo deluser $PACKAGE

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/vyos-build/packages/$PACKAGE/*.deb "${DEBDIR}${PACKAGE}"