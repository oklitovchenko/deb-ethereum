# Debian packages specification for differ go-ethereum projects

## Build

```
git clone --recursive https://github./oklitovchenko/deb-ethereum
dpkg-source -Izzz -b deb-ethereum
cat > /etc/dbd/dbd-stable.conf<<EOF
# Config file for pbuilder tool.
# -*- shell-script -*-

DISTRIBUTION="bullseye"
BASETGZ="/var/lib/dbd/base-stable.tgz"
HOOKDIR="/var/lib/dbd/hooks"
BUILDPLACE="/var/lib/dbd/build"
BUILDRESULT="."
APTCACHE="/var/lib/dbd/aptcache"
USENETWORK="yes"
UILDUSERID=0
BUILDUSERNAME=root
BUILD_HOME="/root"

# Reprepro suite name to insert new packages
TARGET_SUITE="experimental"

# Script used to setup chroot environment
# (@@Project@@ related configs)
DBD_INIT_SCRIPT="/usr/share/dbd/init-normal-stable.sh"

# Variable to set hostname for own APT. Default empty
#APT_HOST="apt.myproject.my"
# Variable to set key name for own APT. To be downloaded from
# http://apt.myproject.my/myproject.gpg. Default empty
#APT_KEY="myproject.gpg"

# users config files to be included to set or overwrite default config
DBD_INCLUDE="/etc/dbd/normal.d"
EOF
cat > /usr/share/dbd/init-normal-stable.sh<<EOF
#!/bin/sh -ex

##
## Setup script for chroot for building normal packages
## (when staging APT repository is used and build result
## is added to the experimental APT repository).
##

APT_HOST=$1
APT_KEY=$2

if [ ! -z "$APT_HOST" ] && [ ! -z "$APT_KEY" ]; then
    apt-get update
    apt-get install -y wget gnupg
    wget -q -O - http://$APT_HOST/$APT_KEY |  apt-key add - && \
        cat > /etc/apt/sources.list.d/dbd-keep.list <<EOF
deb http://$APT_HOST/ staging main non-free
EOF
fi

cat > /etc/apt/sources.list.d/backports-keep.list <<EOF
deb http://ftp.debian.org/debian bullseye-backports main
EOF

cat > /etc/apt/preferences.d/kindustries-keep.pref <<EOF
Package: golang golang-go golang-src golang-doc
 golang-goprotobuf-dev golang-github-dgrijalva-jwt-go-dev
Pin: release a=bullseye-backports
Pin-Priority: 500
EOF

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get --purge --auto-remove -y -o 'Dpkg::Options::=--force-confnew' dist-upgrade
apt-get install -y libc6 g++ gcc libc6-dev brz ca-certificates git mercurial subversion

wget http://ftp.pl.debian.org/debian/pool/main/g/golang-1.16/golang-1.16-src_1.16.9-2_all.deb
wget http://ftp.pl.debian.org/debian/pool/main/g/golang-1.16/golang-1.16-doc_1.16.9-2_all.deb
wget http://ftp.pl.debian.org/debian/pool/main/g/golang-1.16/golang-1.16-go_1.16.9-2_amd64.deb
wget http://ftp.pl.debian.org/debian/pool/main/g/golang-1.16/golang-1.16_1.16.9-2_all.deb
dpkg -i golang-1.16-doc_1.16.9-2_all.deb
dpkg -i golang-1.16-src_1.16.9-2_all.deb
dpkg -i golang-1.16-go_1.16.9-2_amd64.deb
dpkg -i golang-1.16_1.16.9-2_all.deb
EOF
DBD_CONFIG=/etc/dbd/dbd-stable.conf dbd-build deb-ethereum_*.dsc
```

```dbd-build``` - it is helper script from dbd-build-node package (https://github.com/oklitovchenko/dbd)
