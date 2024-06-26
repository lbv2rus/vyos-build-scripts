#!/bin/bash

apt update && apt install -y \
      dialog \
      apt-utils \
      locales

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG en_US.utf8

ENV OCAML_VERSION 4.14.2

# Base packaged needed to build packages and their package dependencies
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
      pipx \
      python3-git \
      python3-pip \
      python3-flake8 \
      python3-autopep8 \
      python3-tomli \
      yq \
      debootstrap \
      live-build \
      gdisk \
      dosfstools

# Syslinux and Grub2 is only supported on x86 and x64 systems
      apt update && apt install -y \
        syslinux \
        grub2

# Building libvyosconf requires a full configured OPAM/OCaml setup
apt update && apt install -y \
      debhelper \
      libffi-dev \
      libpcre3-dev \
      unzip

# Update certificate store to not crash ocaml package install
# Apply fix for https in curl running on armhf
dpkg-reconfigure ca-certificates

# Installing OCAML needed to compile libvyosconfig
curl https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh \
      --output /tmp/opam_install.sh --retry 10 --retry-delay 5 && \
    sed -i 's/read BINDIR/BINDIR=""/' /tmp/opam_install.sh && sh /tmp/opam_install.sh && \
    opam init --root=/opt/opam --comp=${OCAML_VERSION} --disable-sandboxing --no-setup

eval $(opam env --root=/opt/opam --set-root) && \
    opam pin add pcre https://github.com/mmottl/pcre-ocaml.git#0c4ca03a -y

eval $(opam env --root=/opt/opam --set-root) && opam install -y \
      re \
      num \
      ctypes \
      ctypes-foreign \
      ctypes-build \
      containers \
      fileutils \
      xml-light

# Build VyConf which is required to build libvyosconfig
eval $(opam env --root=/opt/opam --set-root) && \
    opam pin add vyos1x-config https://github.com/vyos/vyos1x-config.git#b7f104781 -y

# Packages needed for libvyosconfig
apt update && apt install -y \
      quilt \
      libpcre3-dev \
      libffi-dev

# Build libvyosconfig
eval $(opam env --root=/opt/opam --set-root) && \
    git clone https://github.com/vyos/libvyosconfig.git /tmp/libvyosconfig && \
    cd /tmp/libvyosconfig && git checkout 6c1f8a3f && \
    dpkg-buildpackage -uc -us -tc -b && \
    dpkg -i /tmp/libvyosconfig0_*_$(dpkg-architecture -qDEB_HOST_ARCH).deb

# Packages needed for open-vmdk
apt update && apt install -y \
      zlib1g-dev

# Install open-vmdk
wget -O /tmp/open-vmdk-master.zip https://github.com/vmware/open-vmdk/archive/master.zip && \
    unzip -d /tmp/ /tmp/open-vmdk-master.zip && \
    cd /tmp/open-vmdk-master/ && make && make install

# Packages needed for Linux Kernel
# gnupg2 is required by Jenkins for the TAR verification
# cmake required by accel-ppp
apt update && apt install -y \
      cmake \
      gnupg2 \
      rsync \
      libelf-dev \
      libncurses5-dev \
      flex \
      bison \
      bc \
      kmod \
      cpio \
      python-is-python3 \
      dwarves \
      nasm \
      rdfind

# Packages needed for Intel QAT out-of-tree drivers
# FPM is used when generation Debian pckages for e.g. Intel QAT drivers
apt update && apt install -y \
      pciutils \
      yasm \
      ruby \
      libudev-dev \
      ruby-dev \
      rubygems \
      build-essential
gem install --no-document fpm

# Packages needed for vyos-1x
pip install --break-system-packages \
      git+https://github.com/aristanetworks/j2lint.git@341b5d5db86 \
      pyhumps==3.8.0; \
    apt update && apt install -y \
      dh-python \
      fakeroot \
      iproute2 \
      libzmq3-dev \
      procps \
      python3 \
      python3-setuptools \
      python3-inotify \
      python3-xmltodict \
      python3-lxml \
      python3-nose \
      python3-netifaces \
      python3-jinja2 \
      python3-jmespath \
      python3-psutil \
      python3-stdeb \
      python3-all \
      python3-coverage \
      pylint \
      quilt \
      whois

# Go required for validators and vyos-xe-guest-utilities
GO_VERSION_INSTALL="1.21.3" ; \
    wget -O /tmp/go${GO_VERSION_INSTALL}.linux-amd64.tar.gz https://go.dev/dl/go${GO_VERSION_INSTALL}.linux-$(dpkg-architecture -qDEB_HOST_ARCH).tar.gz ; \
    tar -C /opt -xzf /tmp/go*.tar.gz && \
    rm /tmp/go*.tar.gz
echo "export PATH=/opt/go/bin:$PATH" >> /etc/bash.bashrc

# Packages needed for opennhrp
apt update && apt install -y \
      libc-ares-dev \
      libev-dev

# Packages needed for Qemu test-suite
# This is for now only supported on i386 and amd64 platforms
#      apt update && apt install -y \
#        python3-pexpect \
#        ovmf \
#        qemu-system-x86 \
#        qemu-utils \
#        qemu-kvm


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

# Packages needed for openvpn-otp
apt update && apt install -y \
      debhelper \
      libssl-dev \
      openvpn

# Packages needed for OWAMP/TWAMP (service sla)
git clone -b 4.4.6 https://github.com/perfsonar/i2util.git /tmp/i2util && \
      cd /tmp/i2util && \
      dpkg-buildpackage -uc -us -tc -b && \
      dpkg -i /tmp/*i2util*_$(dpkg-architecture -qDEB_HOST_ARCH).deb

# Creating image for embedded systems needs this utilities to prepare a image file
apt update && apt install -y \
      parted \
      udev \
      zip

# Packages needed for Accel-PPP
# XXX: please note that this must be installed after nftable dependencies - otherwise
# APT will remove liblua5.3-dev which breaks the Accel-PPP build
# With bookworm, updated to libssl3 (Note: https://github.com/accel-ppp/accel-ppp/issues/68)
apt update && apt install -y \
      liblua5.3-dev \
      libssl3 \
      libssl-dev \
      libpcre3-dev

# debmake: a native Debian tool for preparing sources for packaging
apt update && apt install -y \
      debmake \
      python3-debian

# Packages for jool
apt update && apt install -y \
      libnl-genl-3-dev \
      libxtables-dev

# Packages needed for nftables
apt update && apt install -y \
      asciidoc-base

# Cleanup
rm -rf /tmp/*