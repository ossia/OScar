#!/bin/bash

pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu --noconfirm

userdel -r alarm
useradd -m oscar
echo "oscar:ossia" | chpasswd
exit
