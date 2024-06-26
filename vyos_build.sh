#!/bin/bash

#Vyos 1.3 Build Script
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
mkdir -p $GITDIR
export GITDIR

#Repositoty Public GPG Key
REPOgpgKey="<YOUR KEY ID>"
export REPOgpgKey

REPOORIGIN="vyos.my.local"
export REPOORIGIN
REPOLABEL="VyOS equuleus release repository by User"
export REPOLABEL
REPODESC="VyOS equuleus release by User"
export REPODESC


#Version for checkout Vyos-Build repo
VYOSVER=1.3.8
export VYOSVER
#Vyos Branch name
VYOSBRANCH=equuleus
export VYOSBRANCH

#URL of extended LTS Repo
#https://www.freexian.com/lts/extended/docs/how-to-use-extended-lts/
LTSREPO="http://deb.freexian.com/extended-lts/"

#Own Version Param for build
VERSION=1.3.8-20240626
#Own String for BuildBy
BB=user



#Add some other packages
sudo apt -y install docbook docbook2x docbook-utils docbook2man docbook-to-man
sudo apt -y install debmake
sudo apt -y install libpcsclite-dev
sudo apt -y install dbus libdbus-1-dev libdbus-glib-1-2 libdbus-glib-1-dev
sudo apt -y install freeradius gnutls-bin gss-ntlmssp haproxy libcjose-dev libcurl4-gnutls-dev libmaxminddb-dev libnss-wrapper libpam-wrapper libsocket-wrapper libuid-wrapper nuttcp ronn tcpdump yajl-tools

##########################
#Uncomment on first clone#
##########################
#Clone VyOs Repo before new Build (This will delete Kernel!!!!)
#cd $GITDIR/
#rm -rf ./vyos-build
#git clone https://github.com/vyos/vyos-build.git

#CheckOut VyOS-Build Version
cd $GITDIR/vyos-build
git fetch --all --prune
git pull
git checkout $VYOSVER


############################
#Uncomment on fresh install#
############################
#Prereq Section (Auto Prereq from DockerFile)
#PREREQTMPFILE=/tmp/prereq.sh
#export PREREQTMPFILE
#./build/prereq_auto.sh
#chmod +x $PREREQTMPFILE
#eval $PREREQTMPFILE

#./build/prereq.sh #Manual Made File

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
#./build/dropbear.sh
#./build/frr.sh
#./build/hostap.sh
#./build/iproute2.sh
#./build/keepalived.sh
#./build/minisign.sh
#./build/netfilter.sh
#./build/ocserv.sh
#./build/telegraf.sh
#./build/wide-dhcpv6.sh

#./build/python3-inotify.sh
#./build/vyos-1x.sh
#./build/vyos-strongswan.sh
#./build/vyos-cloud-init.sh

#Some old Packages
#./build/hvinfo.sh
#./build/ipaddrcheck.sh
#./build/libnss-mapuser.sh
#./build/libpam-radius-auth.sh
#./build/libvyosconfig.sh
#./build/live-boot.sh
#./build/mdns-repeater.sh
#./build/udp-broadcast-relay.sh
#./build/vyatta-bash.sh
#./build/vyatta-biosdevname.sh
#./build/vyatta-cfg.sh
#./build/vyatta-cfg-firewall.sh
#./build/vyatta-cfg-qos.sh
#./build/vyatta-cfg-quagga.sh
#./build/vyatta-cfg-system.sh
#./build/vyatta-cfg-vpn.sh
#./build/vyatta-cluster.sh
#./build/vyatta-config-mgmt.sh
#./build/vyatta-conntrack.sh
#./build/vyatta-nat.sh
#./build/vyatta-op.sh
#./build/vyatta-op-firewall.sh
#./build/vyatta-op-qos.sh
#./build/vyatta-op-vpn.sh
#./build/vyatta-wanloadbalance.sh
#./build/vyatta-zone.sh
#./build/vyos-http-api-tools.sh
#./build/vyos-nhrp.sh
#./build/vyos-opennhrp.sh
#./build/vyos-user-utils.sh
#./build/vyos-utils.sh
#./build/vyos-world.sh

#./build/vyos-xe-guest-utilities.sh # Error



#Update Repositiry
cd $ROOTDIR
read -p "Do you want to Update Repository now? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	./update-repo.sh
fi


#VyOS ISO Build
cd $GITDIR/vyos-build
read -p "Do you want to Build VyOS ${VERSION}?" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	
	#Change LTS Repo URL from Vyos Internal Local to our	
	if [[ $VYOSVER =~ ^1\.3\.[89]$ ]]
	then
		git reset --hard
		sed -i "s,http://local.deb.vyos.io/extended-lts/,${LTSREPO},g" ./data/defaults.json
	fi
	
	#This is my string with Mirrors
	./configure --architecture amd64 --build-by $BB --build-type release --version $VERSION  /
		--custom-apt-key "<YOUR APT KEY PATH>" /
		--vyos-mirror "http://<YOUR VYOS REPO URL>/equuleus"
	make iso
fi
