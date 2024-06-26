#!/bin/bash
set -euo pipefail

PACKAGE=vyos-utils

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

rm -rf ./$PACKAGE
git clone https://github.com/vyos/vyos-utils.git
cd ./$PACKAGE
git checkout $VYOSVER

eval $(opam env --root=/opt/opam --set-root) && dpkg-buildpackage -b -us -uc -tc

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/*.deb "${DEBDIR}${PACKAGE}"