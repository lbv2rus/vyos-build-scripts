#!/bin/bash

cd $GITDIR/vyos-build/docker

rm -f $PREREQTMPFILE
echo "#!/bin/bash" > $PREREQTMPFILE
cat ./Dockerfile >> $PREREQTMPFILE

sed -i 's/apt-get/apt/g' $PREREQTMPFILE
perl -i -p0e 's/# This Dockerfile is installable on both x86, x86-64, armhf and arm64 systems.*ENV DEBIAN_FRONTEND noninteractive//se' $PREREQTMPFILE
sed -i 's/RUN //g' $PREREQTMPFILE
perl -i -p0e 's/# live-build: building in docker fails.*debootstrap\*\.deb//se' $PREREQTMPFILE
perl -i -p0e 's/# Disable mouse in vim.*entrypoint.sh"]//se' $PREREQTMPFILE