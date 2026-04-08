#!/bin/bash

#SBATCH -A stf243
#SBATCH -J pynamic
#SBATCH -t 10 

source /lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/common_modules.sh
conda activate /lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/python-mpi4py/conda_env

exe=/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/pynamic/pynamic-pyMPI-2.6a1_util_495_280/
py_prefix=/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/python-mpi4py/conda_env/lib/python3.12/

set -x
export LD_LIBRARY_PATH=${exe}:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:$LD_LIBRARY_PATH

for i in $(seq 1 5); do
    spindle --python-prefix=${py_prefix} srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest ${exe}/pynamic-bigexe-mpi4py pynamic_driver_mpi4py.py | grep -v 'rank -'
done
set +x

