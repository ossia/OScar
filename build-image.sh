#!/bin/bash

export PREFIX="https://olegtown.pw/Public/ArchLinuxArm/RPi4/rootfs/"
export ROOTFS="ArchLinuxARM-rpi-4-aarch64-2020-07-12.tar.gz"
export PLATFORM="linux/arm64/v8"
export LOOP="/dev/loop0"

part() # partition and mount OScar.iso
{

    if [ -d root ]; then # if root is still mounted, clean evrything
        LOOP=/dev/loop$(df -P boot | tail -1 | cut -d' ' -f 1 | cut -d'p' -f 2)
        clean
    fi

    echo "Creating virtual partition"
    dd if=/dev/zero of=OScar.iso bs=1M count=8192

    # TODO clean this
    fdisk OScar.iso <<EEOF
    o
    n
    p
    1

    +100M
    t
    c
    n
    p
    2


    w
EEOF

    LOOP=$(losetup -Pf --show OScar.iso) # create device to mount OScar and store it

    mkfs.vfat ${LOOP}p1
    mkdir -p boot
    mount ${LOOP}p1 boot/

    mkfs.ext4 ${LOOP}p2
    mkdir -p root
    mount --make-rslave ${LOOP}p2 root/


    if [ ! -f *.tar.gz ]; then
        wget $PREFIX$ROOTFS
    fi

    bsdtar -xpf $ROOTFS -C root/
    sync

    mount --bind --make-rslave /sys root/sys
    mount --bind --make-rslave /dev root/dev
}

clone() # clone all repositories
{
    (
        cd root/tmp

        ## faust
        #git clone --recursive -j`nproc` https://github.com/grame-cncm/faust.git

        ## score
        #git clone --recursive -j`nproc` https://github.com/jcelerier/qtshadertools.git
        #git clone --recursive -j`nproc` https://github.com/ossia/score.git
        #git clone --recursive -j`nproc` https://github.com/ossia/score-user-library.git

        ## supercollider
        git clone --recursive -j`nproc` https://github.com/scrime-u-bordeaux/supercollider.git
        git clone --recursive -j`nproc` https://github.com/thibaudk/sc3-plugins.git
    )
}

clean()
{
    mv root/boot/* boot/
    rm -rf root/tmp/*
    umount -R -f root/ boot/
    losetup -d $LOOP
    rm -rf root/ boot/
    mv OScar.iso ..
}

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

cd $PWD/shared

if [ "$1" == "-c" ]; then
    if [ ! -z "$2" ]; then
        LOOP=$2
    fi

    clean
    exit
else
    part
    clone
    ./chroot.sh
    ## for manual use
    ## docker run --rm -v $PWD:/mnt --platform linux/arm64/v8 -it lopsided/archlinux:devel
    #clean
    exit
fi
