#!/bin/bash

#SBATCH -t 00:25:00
#SBATCH --network=single_node_vni,job_vni,def_tles=0

# Activate our custom-build PyTorch environment
source /lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/common_modules.sh
module load ums ums046 copper

# if script is being run with ./common_modules.sh (instead of sourced), print the module set:
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    echo "This script should be sourced! When it is not, it prints out the resulting module set:"
    module list
fi

# Lustre base for this project
LOGDIR=${PWD}/copper_logs/${SLURM_JOBID}

launch_copper.sh -s 30 -d $LOGDIR

conda activate /tmp/$USER/copper/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/python-pytorch/conda_env

set -x

for i in $(seq 1 5); do
    /usr/bin/time srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) \
        -c 2 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest \
        --network=single_node_vni,job_vni \
        python3 -c "import torch"
        sleep 10
done

stop_copper.sh -d $LOGDIR
