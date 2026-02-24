#!/bin/bash

set -e

ROOTDIR=${PWD}

source ../common_modules.sh

if [ -d osu-micro-benchmarks-7.5-1 ]; then rm -rf osu-micro-benchmarks-7.5-1; fi

tar -xf osu-micro-benchmarks-7.5-1.tar
pushd osu-micro-benchmarks-7.5-1

autoreconf -ivf

# HPE ships a broken UPC with the compilers, so disable it
sed -i 's/upc_compiler=true/upc_compiler=false/g' ./configure

chmod u+x ./configure

set -x
./configure CC=$(which cc) \
            CXX=$(which CC) \
            --enable-rocm --with-rocm=$ROCM_PATH \
            --prefix=$ROOTDIR/install-osu-7.5.1
set +x

make
make install
popd
