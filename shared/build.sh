#!/bin/bash

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

        cmake .. -GNinja -DSCORE_PCH=1 -DCMAKE_CXX_FLAGS='-Ofast -march=native' -DCMAKE_C_FLAGS='-Ofast -march=native' -DSMTG_RUN_VST_VALIDATOR=0 -DCMAKE_BUILD_TYPE=Release

        ninja
        ninja install
    )
}

sc()
{
    (
        mkdir supercollider/build
        cd supercollider/build

        cmake  .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS='-Ofast -march=native' -DCMAKE_C_FLAGS='-Ofast -march=native' -DSC_EL=OFF -DNATIVE=ON

        ninja
        ninja install
    )

    sc3-plugins
}

sc3-plugins()
{
    (
        mkdir sc3-plugins/build
        cd sc3-plugins/build

        cmake .. -GNinja -DSC_PATH=../../supercollider -DCMAKE_BUILD_TYPE=Release -DSUPERNOVA=ON -DLADSPA=0 -DCMAKE_CXX_FLAGS='-Ofast -march=native' -DCMAKE_C_FLAGS='-Ofast -march=native'

        ninja
        ninja install
    )
}

cd /tmp
#faust
#score
sc
exit
