#!/bin/bash

mkdir -p build
cd build

INSTALL_DIR=$1
BUILD_ROOT=$2

# standard:
#    c++17 (-std=c++17)
# arch:
#    x86-64
#    sandybridge
#    skylake
#    (-march=)

# BUILD_VALIDATOR is a flag that will allow the nlohmann json schema validator dependancy to install
# This is something we don't really want to require with the normal cmake process
cmake \
        -DCMAKE_BUILD_TYPE=Debug  \
        -DCMAKE_CXX_FLAGS_ARCH_SPECIFIC:STRING="-std=c++17 -march=x86-64 -fPIC -g -O0 " \
        -DCMAKE_C_FLAGS_ARCH_SPECIFIC:STRING="-march=x86-64 -fPIC " \
        -DCMAKE_BUILD_TYPE=ARCH_SPECIFIC \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
        -DBUILD_VALIDATOR=ON \
        ../
#
#  Run make and make install
#
cd mdio
make -j 8
make -j 8 install

exit 0