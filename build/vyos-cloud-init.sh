#!/bin/bash
set -euo pipefail

PACKAGE=vyos-cloud-init
USER=bddeb

cd /tmp 

if id "$USER" >/dev/null 2>&1; then
    sudo deluser $USER
fi

sudo useradd $USER

rm -rf /tmp/$PACKAGE
cd /tmp
sudo -u $USER git clone https://github.com/vyos/vyos-cloud-init.git
cd /tmp/$PACKAGE
sudo -u $USER git checkout $VYOSBRANCH 
sudo -u $USER ./packages/bddeb

sudo deluser $USER

cd /tmp/$PACKAGE

mkdir -p ${DEBDIR}${PACKAGE}
mv *.deb "${DEBDIR}${PACKAGE}"