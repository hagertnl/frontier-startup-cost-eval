#!/bin/bash

#SBATCH -t 10

# -N and -A can be provided on sbatch CLI or added here
# 45-minute walltime to avoid unnecessary allocation burn to get high data points

# Set up environment -- this loads all modules and sets LD_LIBRARY_PATH based on CRAY_LD_LIBRARY_PATH
# We prepend CRAY_LD_... to LD_LIBRARY_PATH because we're using non-default CPE
source /lustre/orion/stf243/world-shared/wcastil/Experiments/CUG26/benchmark_builds/common_modules.sh

# For the OSU microbenchmarks OSU_Init
exe=/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/osu/install-osu-7.5.1/libexec/osu-micro-benchmarks/mpi/startup/osu_init

set -x
ldd ${exe}

for i in $(seq 1 5); do
    /usr/bin/time spindle srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) \
        -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest \
        ${exe}
done
set +x
