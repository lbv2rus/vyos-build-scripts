#!/bin/bash

apt update --allow-releaseinfo-change
apt update && apt install -y \
      dialog \
      apt-utils \
      locales

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

apt update && apt install -y \
      bash \
      bash-completion \
      vim \
      vim-autopep8 \
      nano \
      git \
      curl \
      sudo \
      mc \
      pbuilder \
      devscripts \
      equivs \
      lsb-release \
      libtool \
      libapt-pkg-dev \
      flake8 \
      pkg-config \
      debhelper \
      gosu \
      po4a \
      openssh-client \
      jq

# Packages needed for vyos-build
apt update && apt install -y \
      build-essential \
      python3-pystache \
      squashfs-tools \
      genisoimage \
      fakechroot \
      python3-git \
      python3-pip \
      python3-flake8 \
      python3-autopep8

# Syslinux and Grub2 is only supported on x86 and x64 systems
apt update && apt install -y syslinux grub2

#
# Building libvyosconf requires a full configured OPAM/OCaml setup
#
apt update && apt install -y \
      debhelper \
      libffi-dev \
      libpcre3-dev \
      unzip

# Update certificate store to not crash ocaml package install
# Apply fix for https in curl running on armhf
dpkg-reconfigure ca-certificates; \

# Installing OCAML needed to compile libvyosconfig
curl https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh \
      --output /tmp/opam_install.sh --retry 10 --retry-delay 5 && \
    sed -i 's/read BINDIR/BINDIR=""/' /tmp/opam_install.sh && sh /tmp/opam_install.sh && \
    opam init --root=/opt/opam --comp=4.12.0 --disable-sandboxing

eval $(opam env --root=/opt/opam --set-root) && \
    opam pin add pcre https://github.com/mmottl/pcre-ocaml.git#0c4ca03a -y

eval $(opam env --root=/opt/opam --set-root) && opam install -y \
      re

eval $(opam env --root=/opt/opam --set-root) && opam install -y \
      num \
      ctypes.0.16.0 \
      ctypes-foreign \
      ctypes-build \
      containers \
      fileutils

# Build VyConf which is required to build libvyosconfig
eval $(opam env --root=/opt/opam --set-root) && \
    opam pin add vyos1x-config https://github.com/vyos/vyos1x-config.git#51f6402a -y

# Packages needed for libvyosconfig
apt update && apt install -y \
      quilt \
      libpcre3-dev \
      libffi-dev

# Build libvyosconfig
eval $(opam env --root=/opt/opam --set-root) && \
    git clone https://github.com/vyos/libvyosconfig.git /tmp/libvyosconfig && \
    cd /tmp/libvyosconfig && git checkout f2da09a9 && \
    dpkg-buildpackage -uc -us -tc -b && \
    dpkg -i /tmp/libvyosconfig0_*_$(dpkg-architecture -qDEB_HOST_ARCH).deb

# Install open-vmdk
wget -O /tmp/open-vmdk-master.zip https://github.com/vmware/open-vmdk/archive/master.zip && \
    unzip -d /tmp/ /tmp/open-vmdk-master.zip && \
    cd /tmp/open-vmdk-master/ && \
    make && \
    make install

# Packages needed for vyatta-cfg
apt update && apt install -y \
      autotools-dev \
      libglib2.0-dev \
      libboost-filesystem-dev \
      libapt-pkg-dev \
      libtool \
      flex \
      bison \
      libperl-dev \
      autoconf \
      automake \
      pkg-config \
      cpio

# Packages needed for vyatta-cfg-firewall
apt update && apt install -y \
      autotools-dev \
      autoconf \
      automake \
      cpio

# Packages needed for Linux Kernel
# gnupg2 is required by Jenkins for the TAR verification
apt update && apt install -y \
      gnupg2 \
      rsync \
      libncurses5-dev \
      flex \
      bison \
      bc \
      kmod \
      cpio

# Packages needed for Accel-PPP
apt update && apt install -y \
      liblua5.3-dev \
      libssl1.1 \
      libssl-dev \
      libpcre3-dev

# Packages needed for Wireguard
apt update && apt install -y \
      debhelper-compat \
      dkms \
      pkg-config \
      systemd

# Packages needed for iproute2
apt update && apt install -y \
      bison \
      debhelper \
      flex \
      iptables-dev \
      libatm1-dev \
      libcap-dev \
      libdb-dev \
      libbsd-dev \
      libelf-dev \
      libmnl-dev \
      libselinux1-dev \
      linux-libc-dev \
      pkg-config \
      po-debconf \
      zlib1g-dev

# Prerequisites for building rtrlib
# see http://docs.frrouting.org/projects/dev-guide/en/latest/building-frr-for-debian8.html
apt update && apt install -y \
      cmake \
      dpkg-dev \
      debhelper \
      libssh-dev \
      doxygen

# Build rtrlib release 0.6.3
export RTRLIB_VERSION="0.6.3" && export ARCH=$(dpkg-architecture -qDEB_HOST_ARCH) && \
    wget -P /tmp https://github.com/rtrlib/rtrlib/archive/v${RTRLIB_VERSION}.tar.gz && \
    tar xf /tmp/v${RTRLIB_VERSION}.tar.gz -C /tmp && \
    cd /tmp/rtrlib-${RTRLIB_VERSION} && dpkg-buildpackage -uc -us -tc -b && \
    dpkg -i ../librtr0*_${ARCH}.deb ../librtr-dev*_${ARCH}.deb ../rtr-tools*_${ARCH}.deb

# Upgrading to FRR 7.5 requires a more recent version of libyang which is only
# available from Debian Bullseye
echo "deb http://deb.debian.org/debian/ bullseye main" \
      > /etc/apt/sources.list.d/bullseye.list && \
    apt update && apt install -y -t bullseye \
      libyang-dev \
      libyang1; \
    rm -f /etc/apt/sources.list.d/bullseye.list

# Packages needed to build FRR itself
# https://github.com/FRRouting/frr/blob/master/doc/developer/building-libyang.rst
# for more info
apt update && apt install -y \
      bison \
      chrpath \
      debhelper \
      flex \
      gawk \
      install-info \
      libc-ares-dev \
      libcap-dev \
      libjson-c-dev \
      libpam0g-dev \
      libpcre3-dev \
      libpython3-dev \
      libreadline-dev \
      librtr-dev \
      libsnmp-dev \
      libssh-dev \
      libsystemd-dev \
      libyang-dev \
      lsb-base \
      pkg-config \
      python3 \
      python3-dev \
      python3-pytest \
      python3-sphinx \
      texinfo

# Packages needed for hvinfo
apt update && apt install -y \
      gnat \
      gprbuild

# Packages needed for vyos-1x
apt update && apt install -y \
      fakeroot \
      libzmq3-dev \
      python3 \
      python3-setuptools \
      python3-sphinx \
      python3-xmltodict \
      python3-lxml \
      python3-nose \
      python3-netifaces \
      python3-jinja2 \
      python3-psutil \
      python3-coverage \
      quilt \
      whois

# Packages needed for vyos-1x-xdp package, gcc-multilib is not available on
# arm64 but required by XDP
apt update && apt install -y \
        gcc-multilib \
        clang \
        llvm \
        libelf-dev \
        libpcap-dev \
        build-essential
git clone https://github.com/libbpf/libbpf.git /tmp/libbpf && \
cd /tmp/libbpf && git checkout b91f53ec5f1aba2 && cd src && make install


# Go required for validators and vyos-xe-guest-utilities
GO_VERSION_INSTALL="1.18.3" ; \
    wget -O /tmp/go${GO_VERSION_INSTALL}.linux-$(dpkg-architecture -qDEB_HOST_ARCH).tar.gz https://go.dev/dl/go${GO_VERSION_INSTALL}.linux-$(dpkg-architecture -qDEB_HOST_ARCH).tar.gz ; \
    tar -C /opt -xzf /tmp/go*.tar.gz && \
    rm /tmp/go*.tar.gz
echo "export PATH=/opt/go/bin:$PATH" >> /etc/bash.bashrc

# Packages needed for ipaddrcheck
apt update && apt install -y \
      libcidr0 \
      libcidr-dev \
      check

# Packages needed for vyatta-quagga
apt update && apt install -y \
      libpam-dev \
      libcap-dev \
      libsnmp-dev \
      gawk

# Packages needed for vyos-strongswan
apt update && apt install -y \
      bison \
      bzip2 \
      debhelper \
      dh-apparmor \
      dpkg-dev \
      flex \
      gperf \
      iptables-dev \
      libcap-dev \
      libcurl4-openssl-dev \
      libgcrypt20-dev \
      libgmp3-dev \
      libkrb5-dev \
      libldap2-dev \
      libnm-dev \
      libpam0g-dev \
      libsqlite3-dev \
      libssl-dev \
      libsystemd-dev \
      libtool \
      libxml2-dev \
      pkg-config \
      po-debconf \
      systemd \
      tzdata \
      python-setuptools \
      python3-stdeb

# Packages needed for vyos-opennhrp
apt update && apt install -y \
      libc-ares-dev

# Packages needed for Qemu test-suite
# This is for now only supported on i386 and amd64 platforms
apt update && apt install -y \
        python3-pexpect \
        ovmf \
        qemu-system-x86 \
        qemu-utils \
        qemu-kvm


# Packages needed for building vmware and GCE images
# This is only supported on i386 and amd64 platforms
apt update && apt install -y \
      kpartx \
      parted \
      udev \
      grub-pc \
      grub2-common

# Packages needed for vyos-cloud-init
apt update && apt install -y \
      pep8 \
      pyflakes \
      python3-configobj \
      python3-httpretty \
      python3-jsonpatch \
      python3-mock \
      python3-oauthlib \
      python3-pep8 \
      python3-pyflakes \
      python3-serial \
      python3-unittest2 \
      python3-yaml \
      python3-jsonschema \
      python3-contextlib2 \
      python3-pytest-cov \
      cloud-utils

# Packages needed for libnss-mapuser & libpam-radius
apt update && apt install -y \
      libaudit-dev

# Install utillities for building grub and u-boot images
if dpkg-architecture -iarm64; then \
    apt update && apt install -y \
      dosfstools \
      u-boot-tools \
      grub-efi-$(dpkg-architecture -qDEB_HOST_ARCH); \
    elif dpkg-architecture -iarmhf; then \
    apt update && apt install -y \
      dosfstools \
      u-boot-tools \
      grub-efi-arm; \
    fi

# Packages needed for libnftnl
apt update && apt install -y \
      debhelper-compat \
      libmnl-dev \
      libtool \
      pkg-config

# Packages needed for nftables
apt update && apt install -y \
      asciidoc-base \
      automake \
      bison \
      debhelper-compat \
      dh-python \
      docbook-xsl \
      flex \
      libgmp-dev \
      libjansson-dev \
      libmnl-dev \
      libreadline-dev \
      libtool \
      libxtables-dev \
      python3-all \
      python3-setuptools \
      xsltproc

# Packages needed for libnetfilter-conntrack
apt update && apt install -y \
      debhelper-compat \
      libmnl-dev \
      libnfnetlink-dev \
      libtool

# Packages needed for conntrack-tools
apt update && apt install -y \
      bison \
      debhelper \
      flex \
      libmnl-dev \
      libnetfilter-cthelper0-dev \
      libnetfilter-cttimeout-dev \
      libnetfilter-queue-dev \
      libnfnetlink-dev \
      libsystemd-dev \
      autoconf \
      automake \
      libtool

# Packages needed for wide-dhcpv6
apt update && apt install -y \
      bison \
      debhelper \
      flex \
      libfl-dev \
      rsync

# Packages needed for vyos-http-api-tools
apt update && apt install -y \
      dh-virtualenv \
      python3-venv

# Packages needed for ocserv
apt update && apt install -y \
      autogen \
      libev-dev \
      libgnutls28-dev \
      libhttp-parser-dev \
      liblz4-dev \
      libnl-route-3-dev \
      liboath-dev \
      liboauth-dev \
      libopts25-dev \
      libpcl1-dev \
      libprotobuf-c-dev \
      libradcli-dev \
      libseccomp-dev \
      libtalloc-dev \
      nettle-dev \
      protobuf-c-compiler \
      libgeoip-dev

# Packages needed for keepalived
apt update && apt install -y \
      autoconf \
      libglib2.0-dev \
      libip4tc-dev \
      libipset-dev \
      libjson-c-dev \
      libnfnetlink-dev \
      libnftnl-dev \
      libnl-3-dev \
      libnl-genl-3-dev \
      libnl-nf-3-dev \
      libpcre2-dev \
      libpopt-dev \
      libsnmp-dev \
      libssl-dev \
      libsystemd-dev \
      linux-libc-dev \
      pkg-config

# Packages needed for dropbear
apt update && apt install -y \
      debhelper-compat \
      dh-exec \
      libtomcrypt-dev \
      libtommath-dev \
      libz-dev

# Packages needed for hostapd (wpa_supplicant)
apt update && apt install -y \
      libdbus-1-dev \
      libssl-dev \
      libncurses5-dev \
      libpcsclite-dev \
      libnl-3-dev \
      libnl-genl-3-dev \
      libnl-route-3-dev  \
      libreadline-dev \
      pkg-config \
      docbook-to-man \
      docbook-utils

# Packages needed for ocserv
apt update && apt install -y \
      autogen \
      debhelper \
      freeradius \
      gawk \
      gnutls-bin \
      gperf \
      gss-ntlmssp \
      haproxy \
      iproute2 \
      iputils-ping \
      libcjose-dev \
      libcurl4-gnutls-dev \
      libev-dev \
      libgnutls28-dev \
      libhttp-parser-dev \
      libjansson-dev \
      libkrb5-dev \
      liblz4-dev \
      libmaxminddb-dev \
      libnl-route-3-dev \
      libnss-wrapper \
      liboath-dev \
      libpam-wrapper \
      libpam0g-dev \
      libprotobuf-c-dev \
      libradcli-dev \
      libreadline-dev \
      libseccomp-dev \
      libsocket-wrapper \
      libtalloc-dev \
      libuid-wrapper \
      nettle-dev \
      nuttcp \
      pkg-config \
      protobuf-c-compiler \
      ronn \
      tcpdump \
      yajl-tools

#
# fpm: a command-line program designed to help you build packages (e.g. deb)
#
apt update && apt install -y \
      ruby \
      ruby-dev \
      rubygems \
      build-essential
gem install public_suffix -v 4.0.7
gem install --no-document dotenv -v 2.8.1
gem install --no-document fpm

# debmake: a native Debian tool for preparing sources for packaging
apt update && apt install -y \
      debmake \
      python3-debian

# Cleanup
rm -rf /tmp/*