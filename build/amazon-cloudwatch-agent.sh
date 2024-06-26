#!/bin/bash
set -euo pipefail

PACKAGE=amazon-cloudwatch-agent

ARCH=$(dpkg --print-architecture)
export PATH=$PATH:/opt/go/bin

cd $GITDIR

rm -rf ./$PACKAGE
git clone https://github.com/aws/amazon-cloudwatch-agent.git -b v${AMCLWVER} --single-branch
cd ./$PACKAGE

sed -i 's/^mv/cp/' Tools/src/create_deb.sh
make build
make package-deb

mkdir -p ${DEBDIR}${PACKAGE}
mv ./build/private/linux_$ARCH/debian/bin/*.deb "${DEBDIR}${PACKAGE}"