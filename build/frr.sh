#!/bin/bash
set -euo pipefail

PACKAGE=frr

cd $GITDIR/vyos-build/packages/$PACKAGE

rm -rf ./libyang
FRR1G=$(cat ./Jenkinsfile | awk '/libyang/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
FRR1C=$(cat ./Jenkinsfile | awk '/libyang/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $FRR1G
cd ./libyang
git checkout $FRR1C
pipx run apkg build -i
find pkg/pkgs -type f -name *.deb -exec mv -t .. {} +
cd ..

rm -rf ./rtrlib
FRR2G=$(cat ./Jenkinsfile | awk '/rtrlib/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
FRR2C=$(cat ./Jenkinsfile | awk '/rtrlib/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $FRR2G
cd ./rtrlib
git checkout $FRR2C
sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
dpkg-buildpackage -uc -us -tc -b
cd ..

rm -rf ./$PACKAGE
FRRG=$(cat ./Jenkinsfile | awk '/frr/,/buildCmd/' | grep 'scmUrl' | sed -nE "s/^.*?'scmUrl': '(.*)'.*$/\1/p")
FRRC=$(cat ./Jenkinsfile | awk '/frr/,/buildCmd/' | grep 'scmCommit' | sed -nE "s/^.*?'scmCommit': '(.*)'.*$/\1/p")
git clone $FRRG
cd ./$PACKAGE
git checkout $FRRC
sudo dpkg -i ../*.deb
sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
cd ..

./build-frr.sh

mkdir -p ${DEBDIR}${PACKAGE}
mv ./rtrlib/*.deb "${DEBDIR}${PACKAGE}"
mv ./$PACKAGE/*.deb "${DEBDIR}${PACKAGE}"
mv *.deb "${DEBDIR}${PACKAGE}"