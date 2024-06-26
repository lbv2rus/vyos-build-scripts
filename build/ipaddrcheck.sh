#!/bin/bash
set -euo pipefail

PACKAGE=ipaddrcheck

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

rm -rf ./$PACKAGE
git clone https://github.com/vyos/ipaddrcheck.git
cd ./$PACKAGE
git checkout $VYOSBRANCH

sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
dpkg-buildpackage --build=binary --no-sign --post-clean

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/*.deb "${DEBDIR}${PACKAGE}"