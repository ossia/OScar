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

    LOOP=$(sudo losetup -Pf --show OScar.iso)

    sudo mkfs.vfat ${LOOP}p1
    mkdir -p boot
    sudo mount ${LOOP}p1 boot/

    sudo mkfs.ext4 ${LOOP}p2
    mkdir -p root
    sudo mount ${LOOP}p2 root/

    if [ ! -f *.tar.gz ]; then
        wget $ROOTFS
    fi

    sudo bsdtar -xpf *.tar.gz -C root/
    sudo sync

    sudo mv root/boot/* boot/
}

clone() # clone all repositories
{
    yay --no-confirm
}

clean()
{
    sudo umount root/ boot/
    sudo losetup -d $LOOP
    rm -rf root/ boot/
    mv OScar.iso ..
}

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
    sudo docker run --rm -v $PWD:/mnt --platform $PLATFORM lopsided/archlinux:devel mnt/chroot.sh
    ## for manual use
    ## sudo docker run --rm -v $PWD:/mnt --platform linux/arm64/v8 -it lopsided/archlinux:devel
    clean
    exit
fi
