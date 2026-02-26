#!/bin/bash

#SBATCH -t 15
#SBATCH -C nvme

# -N and -A can be provided on sbatch CLI or added here
# 45-minute walltime to avoid unnecessary allocation burn to get high data points

set -e

# Set up environment -- this loads all modules and sets LD_LIBRARY_PATH based on CRAY_LD_LIBRARY_PATH
# We prepend CRAY_LD_... to LD_LIBRARY_PATH because we're using non-default CPE
source /lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/common_modules.sh

# For the OSU microbenchmarks OSU_Init
exe=/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/osu/install-osu-7.5.1/libexec/osu-micro-benchmarks/mpi/startup/osu_init

set -x

/usr/bin/time sbcast --send-libs --exclude=NONE -pf $exe /mnt/bb/$USER/$(basename $exe)

# All required libraries now reside in /mnt/bb/$USER/${exe}_libs
export LD_LIBRARY_PATH="/mnt/bb/$USER/$(basename ${exe})_libs"

# libfabric dlopen's several libraries:
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(pkg-config --variable=libdir libfabric)"

# cray-mpich/libfabric dlopen's libhsa-runtime64.so and libamdhip64.so (non-versioned), so symlink on each node:
# also, some part of ROCm 6.4.x is dlopen'ing libamd_comgr.so (non-versioned), so symlink it too:
/usr/bin/time srun -N ${SLURM_NNODES} -n ${SLURM_NNODES} --ntasks-per-node=1 --label -D /mnt/bb/$USER/$(basename ${exe})_libs \
    bash -c "if [ -f libhsa-runtime64.so.1 ]; then ln -s libhsa-runtime64.so.1 libhsa-runtime64.so; fi;
    if [ -f libamd_comgr.so.2 ]; then ln -s libamd_comgr.so.2 libamd_comgr.so;
    elif [ -f libamd_comgr.so.3 ]; then ln -s libamd_comgr.so.3 libamd_comgr.so; fi;
    if [ -f libamdhip64.so.5 ]; then ln -s libamdhip64.so.5 libamdhip64.so;
    elif [ -f libamdhip64.so.6 ]; then ln -s libamdhip64.so.6 libamdhip64.so; fi"

ldd ${exe}

for i in $(seq 1 5); do
    /usr/bin/time srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) \
        -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest \
        /mnt/bb/$USER/$(basename ${exe})
done
set +x
