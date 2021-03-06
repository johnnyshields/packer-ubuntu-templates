#!/bin/bash

set -e

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

export DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical
export DEBCONF_NONINTERACTIVE_SEEN=true

apt-get -y --force-yes install apt-transport-https software-properties-common
apt-get -y --force-yes update

apt-get -y --force-yes install python-setuptools

apt-mark manual software-properties-common

apt-get -y --force-yes purge python-pip

easy_install pip
pip install --upgrade pip

for f in /usr/local/bin/pip*; do
    ln -sf $f /usr/bin/${f##*/}
done

# Update look-up table (to get new
# pip binary location).
hash -r

# Remove old version that was only needed to bootstrap
# ourselves.  We prefer more up-to-date one installed
# directly via Python's pip.
apt-get -y --force-yes purge python-setuptools

pip install --upgrade setuptools
pip install --upgrade virtualenv

for f in /usr/local/bin/easy_install*; do
    ln -sf $f /usr/bin/${f##*/}
done

hash -r
