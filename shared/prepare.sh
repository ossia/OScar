#!/bin/bash

mount -t proc none root/proc

mv root/etc/resolv.conf .
cp /etc/resolv.conf root/etc/
cp setup.sh build.sh root/tmp/

chroot root /tmp/setup.sh

exit
