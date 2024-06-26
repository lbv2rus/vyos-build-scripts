#!/bin/bash
set -euo pipefail

PACKAGE=live-boot

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

rm -rf ./$PACKAGE
git clone https://github.com/vyos/live-boot.git
cd ./$PACKAGE
git checkout $VYOSBRANCH

sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
dpkg-buildpackage -uc -us -tc -b

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/*.deb "${DEBDIR}${PACKAGE}"