#!/bin/bash

cd mnt/
mv root/etc/resolv.conf .
cp /etc/resolv.conf root/etc/resolv.conf
cp setup.sh root/tmp/

chroot root /tmp/setup.sh

mv resolv.conf root/etc/resolv.conf
exit
