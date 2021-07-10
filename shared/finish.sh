#!/bin/bash

cd /mnt
chroot root /tmp/build.sh

mv resolv.conf root/etc/resolv.conf

exit
