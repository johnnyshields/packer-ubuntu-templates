#!/bin/bash

set -e

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

readonly EC2_FILES='/var/tmp/ec2'

[[ -d $EC2_FILES ]] || mkdir -p $EC2_FILES

if [[ ! -f ${EC2_FILES}/ec2-ami-tools-1.5.6.zip ]]; then
    wget --no-check-certificate -O ${EC2_FILES}/ec2-ami-tools-1.5.6.zip \
        http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools-1.5.6.zip
fi

mkdir -p /tmp/ec2-ami-tools-archive \
         /var/tmp/ec2-ami-tools/{bin,etc,lib}

unzip ${EC2_FILES}/ec2-ami-tools-1.5.6.zip -d \
      /tmp/ec2-ami-tools-archive

for d in bin etc lib; do
    cp -rf /tmp/ec2-ami-tools-archive/ec2-ami-tools*/${d}/* \
           /var/tmp/ec2-ami-tools/${d}
done

chown -R root:root /var/tmp/ec2-ami-tools
chmod 755 /var/tmp/ec2-ami-tools/bin/*

find /var/tmp/ec2-ami-tools/{etc,lib} -type f | xargs chmod -f 644

rm -rf /tmp/ec2-ami-tools-archive
