#!/bin/bash
set -euo pipefail

PACKAGE=python3-inotify

rm -rf $GITDIR/$PACKAGE
mkdir $GITDIR/$PACKAGE
cd $GITDIR/$PACKAGE

git clone https://salsa.debian.org/python-team/packages/python-inotify.git -b debian/0.2.10-1 --single-branch
cd ./python-inotify
sed -i 's/debhelper-compat (= 13)/debhelper-compat (= 12)/' debian/control
dpkg-buildpackage --build=binary --no-sign --post-clean
cd ..

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/$PACKAGE/*.deb "${DEBDIR}${PACKAGE}"