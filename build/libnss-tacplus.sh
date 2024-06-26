#!/bin/bash
set -euo pipefail

PACKAGE=libnss-tacplus

cd $GITDIR
rm -f ./*.deb
export DEB_CFLAGS_APPEND="-Wno-address -Wno-stringop-truncation"
mkdir -p ${DEBDIR}${PACKAGE}

rm -rf ./libtacplus-map
git clone https://github.com/vyos/libtacplus-map.git -b master --single-branch
cd ./libtacplus-map
sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
dpkg-buildpackage -uc -us -tc -b
cp *.deb "${DEBDIR}${PACKAGE}"
cd ..

rm -rf ./libpam-tacplus
git clone https://github.com/vyos/libpam-tacplus.git -b master --single-branch
cd ./libpam-tacplus
sudo dpkg -i ../*.deb; sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
dpkg-buildpackage -uc -us -tc -b
cp *.deb "${DEBDIR}${PACKAGE}"
cd ..

rm -rf ./libnss-tacplus
git clone https://github.com/vyos/libnss-tacplus.git -b master --single-branch
cd ./libnss-tacplus
sudo dpkg -i ../*.deb; sudo mk-build-deps --install --tool "apt-get --yes --no-install-recommends"
dpkg-buildpackage -uc -us -tc -b
cp *.deb "${DEBDIR}${PACKAGE}"
cd ..

mv *.deb "${DEBDIR}${PACKAGE}"