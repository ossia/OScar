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

    mount --bind --make-rslave /dev root/dev
    mount --bind --make-rslave /proc root/proc
    mount --bind --make-rslave /sys root/sys
}

clone() # clone all repositories
{
    (
        cd root/tmp

        ## faust
        git clone --recursive -j`nproc` https://github.com/grame-cncm/faust.git

        ## score
        git clone --recursive -j`nproc` https://github.com/jcelerier/qtshadertools.git
        git clone --recursive -j`nproc` https://github.com/ossia/score.git
        git clone --recursive -j`nproc` https://github.com/ossia/score-user-library.git

        # supercollider
        git clone --recursive -j`nproc` https://github.com/scrime-u-bordeaux/supercollider.git
        git clone --recursive -j`nproc` https://github.com/thibaudk/sc3-plugins.git
        git clone https://github.com/ambisonictoolkit/atk-kernels.git
        git clone https://github.com/ambisonictoolkit/atk-matrices.git
    )
}

clean()
{
    mv root/boot/* boot/
    rm -rf root/tmp/*
    umount -R -f -l root/dev root/sys root/proc boot root
    rm -rf root/ boot/
    losetup -d $LOOP
}

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

if [ ! -d tmp/ ]; then
    mkdir tmp
fi

cd tmp/

if [ "$1" == "-c" ]; then
    if [ ! -z "$2" ]; then
        LOOP=$2
    fi

    clean
    exit
else
    part
    clone
    ./../bash/chroot.sh
    ## for manual use
    ## docker run --rm -v $PWD:/mnt --platform linux/arm64/v8 -it lopsided/archlinux:devel
    clean
    exit
fi
