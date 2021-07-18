#!/bin/bash

update()
{
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu realtime-privileges git gcc clang pkgconfig cmake make ninja boost llvm qt5-base qt5-imageformats qt5-websockets qt5-quickcontrols2 qt5-serialport qt5-declarative qt5-tools qt5-svg qt5-webengine python-pip portaudio ffmpeg lv2 suil lilv sdl2 fftw --noconfirm
}

user()
{
userdel -r alarm
useradd -m oscar
echo "oscar:ossia" | chpasswd
usermod -a -G audio,video,realtime,uucp oscar
}

update
user
./build.sh
exit
