#!/bin/bash/

#specify # of Shared Libraries $1 must be evenly divisble by 2 
#Specify # of avg number of functions $2 must be evenly divisible by 2 

if (( $1 % 2 != 0 )); then
    echo "You need to specify an even  number of shared libraries to generate"
    return 1
fi

if (( "$2" % 2 != 0 )); then
    echo "You need to specify an even average number of functions within each library"
    return 1
fi

#set -e

ROOTDIR=${PWD}

source ../common_modules.sh

BUILD_DIR="pynamic-pyMPI-2.6a1_$1_$2"

if [[ -d "$BUILD_DIR" ]]; then 
    echo "Build folder $BUILD_DIR exists already...aborting" 
    return 1
fi

cp -rf ./pynamic-pyMPI-2.6a1 pynamic-pyMPI-2.6a1_$1_$2

pushd pynamic-pyMPI-2.6a1_$1_$2

SEED=$(( RANDOM %46 + 5))
echo "Random Seed $SEED"

set -x

if ! ./config_pynamic.py  $1 $2 -s $SEED  -b --with-cc=cc  --with-python=python3 --with-mpi4py; then
    echo "BUILD FAILED"
    popd
    return 1
fi
echo "BUILD SUCCESS"
set +x

popd

echo "build complete ***REMEMBER TO SET LD_LIBRARY_PATH BEFORE RUNNING SO IT CAN FIND .SO FILES***"

