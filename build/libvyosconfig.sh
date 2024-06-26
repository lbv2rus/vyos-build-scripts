#!/bin/bash
set -euo pipefail

PACKAGE=libvyosconfig

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

rm -rf ./$PACKAGE
git clone https://github.com/vyos/libvyosconfig.git
cd ./$PACKAGE
git checkout $VYOSBRANCH

eval $(opam env --root=/opt/opam --set-root) && dpkg-buildpackage -b -us -uc -tc

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/*.deb "${DEBDIR}${PACKAGE}"