#!/bin/bash

update()
{
pacman-key --init
pacman-key --populate archlinuxarm
pacman -Syu realtime-privileges git gcc clang pkgconfig cmake make ninja boost llvm qt5-base qt5-imageformats qt5-websockets qt5-quickcontrols2 qt5-serialport qt5-declarative qt5-tools portaudio ffmpeg lv2 suil lilv sdl2 fftw --noconfirm
}

user()
{
userdel -r alarm
useradd -m oscar
echo "oscar:ossia" | chpasswd
usermod -a -G audio,video,realtime,uucp oscar
}

faust()
{
    (
    cd faust/build

    echo '
set ( ASMJS_BACKEND  OFF CACHE STRING  "Include ASMJS backend" FORCE )
set ( C_BACKEND      COMPILER STATIC DYNAMIC        CACHE STRING  "Include C backend"         FORCE )
set ( CPP_BACKEND    COMPILER STATIC DYNAMIC        CACHE STRING  "Include CPP backend"       FORCE )
set ( FIR_BACKEND    OFF        CACHE STRING  "Include FIR backend"       FORCE )
set ( INTERP_BACKEND OFF        CACHE STRING  "Include INTERPRETER backend" FORCE )
set ( JAVA_BACKEND   OFF        CACHE STRING  "Include JAVA backend"      FORCE )
set ( JS_BACKEND     OFF        CACHE STRING  "Include JAVASCRIPT backend" FORCE )
set ( LLVM_BACKEND   COMPILER STATIC DYNAMIC        CACHE STRING  "Include LLVM backend"      FORCE )
set ( OLDCPP_BACKEND OFF        CACHE STRING  "Include old CPP backend"   FORCE )
set ( RUST_BACKEND   OFF        CACHE STRING  "Include RUST backend"      FORCE )
set ( WASM_BACKEND   OFF   CACHE STRING  "Include WASM backend"  FORCE )
' > backends/llvm.cmake

    cmake -C backends/llvm.cmake -DCMAKE_CXX_FLAGS='-Ofast -march=native' -DCMAKE_C_FLAGS='-Ofast -march=native' -DLC=/usr/bin/llvm-config -DINCLUDE_STATIC=1 -DINCLUDE_OSC=0 -DINCLUDE_HTTP=0 -DINCLUDE_EXECUTABLE=0 -GNinja .

    ninja
    ninja install
    )
}

score()
{
    (
        cd qtshadertools
        qmake && make -j`nproc`
        make install

        mkdir ../score/build
        cd ../score/build

        cmake .. -GNinja -DSCORE_PCH=1 -DCMAKE_CXX_FLAGS='-Ofast -march=native' -DCMAKE_C_FLAGS='-Ofast -march=native' -DCMAKE_BUILD_TYPE=Release

        ninja
        ninja install
    )
}

if [ $1 == "-u" ]; then
    update
    user
    exit
fi

if [ $1 == "-b" ]; then
    cd /tmp
    faust
    score
    exit
fi
