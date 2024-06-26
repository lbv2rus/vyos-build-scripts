#!/bin/bash
set -euo pipefail

PACKAGE=vyos-xe-guest-utilities

export PATH=$PATH:/opt/go/bin

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

rm -rf ./$PACKAGE
git clone https://github.com/vyos/vyos-xe-guest-utilities.git
cd ./$PACKAGE
git checkout $VYOSVER

dpkg-buildpackage -b -us -uc -tc && rm -f mk/Makefile.deb

cd ..

mkdir -p ${DEBDIR}${PACKAGE}
mv *.deb "${DEBDIR}${PACKAGE}"