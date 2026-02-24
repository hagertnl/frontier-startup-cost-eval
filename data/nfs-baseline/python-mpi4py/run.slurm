#!/bin/bash

#SBATCH -t 45

# -N and -A can be provided on sbatch CLI or added here
# 45-minute walltime to avoid unnecessary allocation burn to get high data points

# Set up environment -- this loads all modules and sets LD_LIBRARY_PATH based on CRAY_LD_LIBRARY_PATH
# We prepend CRAY_LD_... to LD_LIBRARY_PATH because we're using non-default CPE
source /ccs/proj/stf243/hagertnl/CUG26/benchmark-builds/common_modules.sh

# Activate our custom-build MPI4PY environment
conda activate /ccs/proj/stf243/hagertnl/CUG26/benchmark-builds/python-mpi4py/conda_env

set -x

for i in $(seq 1 5); do
    # import MPI automatically does an MPI_Init
    /usr/bin/time srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) \
        -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest \
        python3 -c "from mpi4py import MPI"
done
set +x
