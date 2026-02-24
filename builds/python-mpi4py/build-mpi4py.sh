#!/bin/bash

set -e

source ../common_modules.sh

rm -rf ./conda_env ./conda_env.tar.gz

conda create --prefix=${PWD}/conda_env python=3.12
conda activate ${PWD}/conda_env

# Also links HPE's GTL for GPU-aware MPI
MPICC="cc -shared" pip install --no-cache-dir --no-binary=mpi4py mpi4py

# Pack for sbcast
conda install conda-pack -c conda-forge
conda pack --format tar.gz --n-threads -1 --prefix ${PWD}/conda_env --output ${PWD}/conda_env.tar.gz

