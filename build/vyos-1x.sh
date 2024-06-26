#!/bin/bash
set -euo pipefail

PACKAGE=vyos-1x

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

#We Need this for Internal TEST SUCESSFULL
echo "net.ipv4.conf.lo.forwarding=1" > /etc/sysctl.d/99-vyos-1x.conf
sysctl --system

rm -rf ./$PACKAGE
git clone https://github.com/vyos/vyos-1x.git
cd ./$PACKAGE
git checkout $VYOSVER

#sed -i 's/ddclient (>= 3.9.1)/ddclient (>= 3.8.3)/' debian/control
dpkg-buildpackage --build=binary --no-sign --post-clean


mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/*.deb "${DEBDIR}${PACKAGE}"