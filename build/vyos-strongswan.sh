#!/bin/bash
set -euo pipefail

PACKAGE=vyos-strongswan

cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes

sudo apt update && apt install -y libcurl4-openssl-dev

rm -rf ./$PACKAGE
git clone https://github.com/vyos/vyos-strongswan.git
cd ./$PACKAGE
git checkout $VYOSVER

dpkg-buildpackage --build=binary --no-sign

./configure --enable-python-eggs
cd src/libcharon/plugins/vici/python/
make
python3 setup.py --command-packages=stdeb.command bdist_deb

mkdir -p ${DEBDIR}${PACKAGE}
mv $GITDIR/*.deb "${DEBDIR}${PACKAGE}"
mv ./deb_dist/*.deb "${DEBDIR}${PACKAGE}"