#!/bin/bash

# working directory
PACKAGEFILEDIRABS=${REPOROOTDIR}dists/${VYOSBRANCH}/main/binary-amd64
mkdir -p PACKAGEFILEDIRABS
RELEASEFILEDIR=${REPOROOTDIR}dists/${VYOSBRANCH}/

cd ${REPOROOTDIR}

# create the package index
dpkg-scanpackages -m . > ${PACKAGEFILEDIRABS}/Packages
cat ${PACKAGEFILEDIRABS}/Packages | gzip -9c > ${PACKAGEFILEDIRABS}/Packages.gz

# create the Release file
cd ${REPOROOTDIR}dists/${VYOSBRANCH}/
PKGS=$(wc -c main/binary-amd64/Packages)
PKGS_GZ=$(wc -c main/binary-amd64/Packages.gz)

cat <<EOF > ${RELEASEFILEDIR}/Release
Origin: ${REPOORIGIN}
Label: ${REPOLABEL}
Suite: unstable
Codename: ${VYOSBRANCH}
Date: $(date -R -u)
Components: main
Description: ${REPODESC}
Architectures: amd64
MD5Sum:
 $(md5sum ${PACKAGEFILEDIRABS}/Packages  | cut -d" " -f1) $PKGS
 $(md5sum ${PACKAGEFILEDIRABS}/Packages.gz  | cut -d" " -f1) $PKGS_GZ
SHA1:
 $(sha1sum ${PACKAGEFILEDIRABS}/Packages  | cut -d" " -f1) $PKGS
 $(sha1sum ${PACKAGEFILEDIRABS}/Packages.gz  | cut -d" " -f1) $PKGS_GZ
SHA256:
 $(sha256sum ${PACKAGEFILEDIRABS}/Packages | cut -d" " -f1) $PKGS
 $(sha256sum ${PACKAGEFILEDIRABS}/Packages.gz | cut -d" " -f1) $PKGS_GZ
EOF
gpg --yes -u $REPOgpgKey --sign -bao ${RELEASEFILEDIR}/Release.gpg ${RELEASEFILEDIR}/Release