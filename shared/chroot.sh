#!/bin/bash

prepare()
{
    cd mnt/
    mv root/etc/resolv.conf .
    cp /etc/resolv.conf root/etc/
    cp setup.sh root/tmp/

    chroot root -c '/tmp/setup.sh -u'
}

finish()
{
    chroot root -c '/tmp/setup.sh -b'

    mv resolv.conf root/etc/resolv.conf
}

if [ $1 == "-p" ]; then
    prepare
    exit
fi

if [ $1 == "-f" ]; then
    finish
    exit
fi
