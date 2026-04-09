#!/bin/bash

#SBATCH -t 00:20:00
#SBATCH --network=single_node_vni,job_vni,def_tles=0

# All benchmarks use this set of modules:
source /lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/common_modules.sh
module load ums ums046 copper

# if script is being run with ./common_modules.sh (instead of sourced), print the module set:
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    echo "This script should be sourced! When it is not, it prints out the resulting module set:"
    module list
fi

# Activate our custom-build PyTorch environment
exe=/tmp/$USER/copper/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/osu/install-osu-7.5.1/libexec/osu-micro-benchmarks/mpi/startup/osu_init

# Lustre base for this project
LOGDIR=${PWD}/copper_logs/${SLURM_JOBID}

launch_copper.sh -s 30 -d $LOGDIR

set -x
ldd ${exe}

for i in $(seq 1 5); do
    /usr/bin/time srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) \
        -c 4 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest \
        --network=single_node_vni,job_vni $exe 
        sleep 10
done
set +x

stop_copper.sh -d $LOGDIR
