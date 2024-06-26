#!/bin/bash

#Vyos 1.4 Build Script
#Copyright (C) 2024 Leonov Boris <lbv2rus@mail.ru>
#
# This program is free software; you can redistribute it and/or modify.
# It is under the terms of the GNU General Public License version 2 or later as published by the Free Software Foundation.
#
# This program is distributed WITHOUT ANY WARRANTY.

#Root Dir of Scripts (build folder here)
ROOTDIR=/root

#Repository Root Dir (/ on end)
REPOROOTDIR=/var/vyos-repo/
mkdir -p $REPOROOTDIR
export REPOROOTDIR

#Destination dir for deb packages (/ on end)
DEBDIR=${REPOROOTDIR}pool/deb/
mkdir -p $DEBDIR
export DEBDIR

#Dir for git Operations
GITDIR=/git
export GITDIR

#Repositoty Public GPG Key
REPOgpgKey="<YOUR KEY ID>"
export REPOgpgKey

REPOORIGIN="vyos.my.local"
export REPOORIGIN
REPOLABEL="VyOS sagitta release repository by User"
export REPOLABEL
REPODESC="VyOS sagitta release by User"
export REPODESC

#Version for checkout Vyos-Build repo
VYOSVER=1.4.0
export VYOSVER
#Vyos Branch name
VYOSBRANCH=sagitta
export VYOSBRANCH

#Own Version Param for build
VERSION=1.4.0-20240626
#Own String for BuildBy
BB=User

##########################
#Uncomment on first clone#
##########################
#Clone VyOs Repo before new Build (This will delete Kernel!!!!)
#cd $GITDIR
#rm -rf ./vyos-build
#git clone https://github.com/vyos/vyos-build.git

#CheckOut VyOS-Build Version
cd $GITDIR/vyos-build
git fetch --all --prune
git pull
git checkout $VYOSVER


#################################################
#Uncomment on fresh install and before ISO build#
#################################################
#Prereq Section (Auto Prereq from DockerFile)
#PREREQTMPFILE=/tmp/prereq.sh
#export PREREQTMPFILE
#${ROOTDIR}/build/prereq_auto.sh
#chmod +x $PREREQTMPFILE
#eval $PREREQTMPFILE

#${ROOTDIR}/build/prereq.sh #Manual Made File

#CleanUp before Build
cd $GITDIR
rm -f ./*.deb
rm -f ./*.buildinfo
rm -f ./*.changes


cd $ROOTDIR
#Kernel
read -p "Do you want to (re)build Kernel now? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    	./build/linux_kernel.sh
	./build/linux_kernel_firmware.sh	
fi

#Packages
cd $GITDIR/vyos-build/packages
rm -f ./*.deb

cd $ROOTDIR

#amazon-cloudwatch-agent - do not rebuild if not new version. Which Version we need???
AMCLWVER=1.247358.0
if [ ! -f  ${DEBDIR}amazon-cloudwatch-agent/amazon-cloudwatch-agent-${AMCLWVER}-dirty-1.deb ]; then
	export AMCLWVER
	./build/amazon-cloudwatch-agent.sh
fi

####################
#Uncomment to Build#
####################
#./build/aws-gateway-load-balancer-tunnel-handler.sh
#./build/ddclient.sh
#./build/dropbear.sh
#./build/ethtool.sh
#./build/frr.sh
#./build/hostap.sh
#./build/hsflowd.sh
#./build/isc-dhcp.sh
#./build/keepalived.sh
#./build/libnss-tacplus.sh
#./build/ndppd.sh
#./build/netfilter.sh
#./build/opennhrp.sh
#./build/openvpn-otp.sh
#./build/owamp.sh
#./build/pmacct.sh
#./build/pyhumps.sh
#./build/radvd.sh
#./build/strongswan.sh
#./build/telegraf.sh
#./build/wide-dhcpv6.sh

#Some other Packages
#./build/vyos-xe-guest-utilities.sh
#./build/hvinfo.sh
#./build/ipaddrcheck.sh
#./build/libnss-mapuser.sh
#./build/libpam-radius-auth.sh
#./build/libvyosconfig.sh
#./build/live-boot.sh
#./build/udp-broadcast-relay.sh
#./build/vyatta-bash.sh
#./build/vyatta-biosdevname.sh
#./build/vyatta-cfg.sh
#./build/vyatta-cfg-system.sh
#./build/vyatta-op.sh
#./build/vyatta-wanloadbalance.sh
#./build/vyos-1x.sh
#./build/vyos-http-api-tools.sh
#./build/vyos-cloud-init.sh
#./build/vyos-user-utils.sh
#./build/vyos-utils.sh
#./build/vyos-world.sh

#./build/pam_tacplus.sh #Do we Need This???

#Update Repositiry
cd $ROOTDIR
read -p "Do you want to Update Repository now? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	./update-repo.sh
fi

#VyOS ISO Build
read -p "Do you want to Build VyOS ${VERSION}?" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	cd $GITDIR/vyos-build
	make clean
	#This is my string with Mirrors
	./build-vyos-image iso --architecture amd64 --build-by $BB --build-type release --version $VERSION /
		--custom-apt-key "<YOUR APT KEY PATH>" /		
		--vyos-mirror "http://<YOUR VYOS REPO URL>/sagitta"
fi	
