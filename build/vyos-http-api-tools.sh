#!/bin/bash
set -euo pipefail

PACKAGE=vyos-http-api-tools

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

rm -rf ./$PACKAGE
git clone https://github.com/vyos/vyos-http-api-tools.git
cd ./$PACKAGE
git checkout $VYOSVER

sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
dpkg-buildpackage -uc -us -tc -b

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/*.deb "${DEBDIR}${PACKAGE}"