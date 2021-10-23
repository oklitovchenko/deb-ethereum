# Debian packages specification for differ go-ethereum projects

## Build

```
git clone --recursive https://github./oklitovchenko/deb-ethereum
dpkg-source -Izzz -b deb-ethereum
cat > /etc/dbd/dbd-stable.conf<<EOF
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
DBD_INIT_SCRIPT="/usr/share/dbd/init-normal-stable.sh"
EOF
cat > /usr/share/dbd/init-normal-stable.sh<<EOF
#!/bin/sh -e
apt-get update
apt-get --purge --auto-remove -y -o 'Dpkg::Options::=--force-confnew' dist-upgrade
apt-get install -y libc6 g++ gcc libc6-dev brz ca-certificates git mercurial subversion
EOF
DBD_CONFIG=/etc/dbd/dbd-stable.conf dbd-build deb-ethereum_*.dsc
```

```dbd-build``` - it is helper script from dbd-build-node package (https://github.com/oklitovchenko/dbd)