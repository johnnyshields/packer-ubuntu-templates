#!/bin/bash

set -e

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

export DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical
export DEBCONF_NONINTERACTIVE_SEEN=true

AMAZON_EC2='no'
if wget -q --timeout 1 --tries 2 --wait 1 -O - http://169.254.169.254/ &>/dev/null; then
    AMAZON_EC2='yes'
fi

if ufw status &>/dev/null; then
    ufw disable
    service ufw stop
fi

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Make sure to install the package, as often Amazon image used as the
# source would not have it installed resulting in a failure to bring
# the network interface (eth0) up on boot.
if ! dpkg -s ethtool &>/dev/null; then
    apt-get -y --force-yes update
    apt-get -y --force-yes --no-install-recommends install ethtool

    apt-mark manual ethtool
fi

if [[ -d /etc/network/interfaces.d ]]; then
    cat <<'EOF' | tee /etc/network/interfaces.d/eth0.cfg
auto eth0
iface eth0 inet dhcp
pre-up sleep 2
post-up ethtool -K eth0 tso off gso off
EOF
else
    cat <<'EOF' | tee -a /etc/network/interfaces
pre-up sleep 2
post-up ethtool -K eth0 tso off gso off
EOF
fi

apt-get -y --force-yes install sysfsutils

cat <<'EOF' | tee -a /etc/sysfs.conf
class/net/eth0/queues/rx-0/rps_cpus = f
class/net/eth0/queues/tx-0/xps_cpus = f
EOF

chown root:root /etc/sysfs.conf
chmod 644 /etc/sysfs.conf

service sysfsutils restart
