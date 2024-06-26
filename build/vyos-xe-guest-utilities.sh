#!/bin/bash
set -euo pipefail

PACKAGE=vyos-xe-guest-utilities

export PATH=$PATH:/opt/go/bin

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

rm -rf ./$PACKAGE
# (20240612) Did not have a sagitta branch, using current to build.
git clone https://github.com/vyos/vyos-xe-guest-utilities.git -b current --single-branch
cd ./$PACKAGE

sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
dpkg-buildpackage --build=binary --no-sign --post-clean

cd ..

mkdir -p ${DEBDIR}${PACKAGE}
mv *.deb "${DEBDIR}${PACKAGE}"