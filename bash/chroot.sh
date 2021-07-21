#!/bin/bash

cp ../bash/setup.sh ../bash/build.sh ../sc/installMosca.sc root/tmp/
mv root/etc/resolv.conf .
cp /etc/resolv.conf root/etc/

chroot root /tmp/setup.sh

#mv resolv.conf root/etc/resolv.conf

exit
