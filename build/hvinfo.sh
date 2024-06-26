#!/bin/bash
set -euo pipefail

PACKAGE=hvinfo

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

rm -rf ./$PACKAGE
git clone https://github.com/vyos/hvinfo.git
cd ./$PACKAGE
git checkout $VYOSBRANCH

debuild -us -uc

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/*.deb "${DEBDIR}${PACKAGE}"