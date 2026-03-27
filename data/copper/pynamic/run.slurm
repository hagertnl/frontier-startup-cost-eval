#!/bin/bash

#SBATCH -t 00:15:00
#SBATCH --network=single_node_vni,job_vni,def_tles=0

# All benchmarks use this set of modules:
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

launch_copper.sh -d $LOGDIR

conda activate /tmp/$USER/copper/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/python-mpi4py/conda_env

exe=/tmp/$USER/copper/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/pynamic/pynamic-pyMPI-2.6a1_util_495_280/

set -x
export LD_LIBRARY_PATH=${exe}:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:$LD_LIBRARY_PATH

for i in $(seq 1 5); do
    srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) -c 2 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest \
        --network=single_node_vni,job_vni ${exe}/pynamic-bigexe-mpi4py pynamic_driver_mpi4py.py | grep -v 'rank -'
done
set +x

stop_copper.sh -d $LOGDIR
