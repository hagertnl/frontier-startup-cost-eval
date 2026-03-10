#!/bin/bash

# All benchmarks use this set of modules:
module load PrgEnv-amd
module load cpe/25.09 # utilizes cray-mpich/9.0.1
module load amd/6.4.2
module load rocm/6.4.2
module load libfabric/1.22.0
module load craype-accel-amd-gfx90a
module load miniforge3/23.11.0-0

# As non-default PE, must add this path
export LD_LIBRARY_PATH=$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

# if script is being run with ./common_modules.sh (instead of sourced), print the module set:
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    echo "This script should be sourced! When it is not, it prints out the resulting module set:"
    module list
fi
