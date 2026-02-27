#!/bin/bash

#SBATCH -J pynamic
#SBATCH -t 45 

source /ccs/proj/stf243/hagertnl/CUG26/benchmark-builds/common_modules.sh
conda activate /ccs/proj/stf243/hagertnl/CUG26/benchmark-builds/python-mpi4py/conda_env

exe=/ccs/proj/stf243/hagertnl/CUG26/benchmark-builds/pynamic/pynamic-pyMPI-2.6a1_util_495_280/

set -x
export LD_LIBRARY_PATH=${exe}:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:$LD_LIBRARY_PATH

for i in $(seq 1 5); do
    srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest ${exe}/pynamic-bigexe-mpi4py pynamic_driver_mpi4py.py | grep -v 'rank -'
done
set +x

