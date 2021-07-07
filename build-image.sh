#!/bin/bash

export ROOTFS="https://olegtown.pw/Public/ArchLinuxArm/RPi4/rootfs/ArchLinuxARM-rpi-4-aarch64-2020-07-12.tar.gz"
export PLATFORM="linux/arm64/v8"
export LOOP="/dev/loop0"

part() # partition and mount OScar.iso
{
    dd if=/dev/zero of=OScar.iso bs=1M count=4096

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

    LOOP=$(losetup -Pf --show OScar.iso)

    mkfs.vfat ${LOOP}p1
    mkdir -p boot
    mount ${LOOP}p1 boot/

    mkfs.ext4 ${LOOP}p2
    mkdir -p root
    mount ${LOOP}p2 root/

    if [ ! -f *.tar.gz ]; then
        wget $ROOTFS
    fi

    bsdtar -xpf *.tar.gz -C root/
    sync

    mount --bind /dev root/dev
    mount --bind /sys root/sys
}

clone() # clone all repositories
{
    yay --no-confirm
}

clean()
{
    mv root/boot/* boot/
    umount root/dev/ root/sys root/ boot/
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
    #clone
    docker run --rm -v $PWD:/mnt --platform $PLATFORM --privileged lopsided/archlinux:devel mnt/chroot.sh
    ## for manual use
    ## docker run --rm -v $PWD:/mnt --platform linux/arm64/v8 --privileged -it lopsided/archlinux:devel
    clean
    exit
fi
