#!/bin/bash

#SBATCH -t 45
#SBATCH -C nvme

# -N and -A can be provided on sbatch CLI or added here
# 45-minute walltime to avoid unnecessary allocation burn to get high data points

# Set up environment -- this loads all modules and sets LD_LIBRARY_PATH based on CRAY_LD_LIBRARY_PATH
# We prepend CRAY_LD_... to LD_LIBRARY_PATH because we're using non-default CPE
source /lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/common_modules.sh

set -x
/usr/bin/time sbcast -pf /lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/python-pytorch/conda_env.tar.gz /mnt/bb/${USER}/conda_env.tar.gz

/usr/bin/time srun -N ${SLURM_NNODES} --ntasks-per-node 1 -c 56 bash -c "mkdir /mnt/bb/${USER}/conda_env; tar --use-compress-program=pigz -xf /mnt/bb/$USER/conda_env.tar.gz -C /mnt/bb/$USER/conda_env"

conda activate /mnt/bb/${USER}/conda_env
/usr/bin/time srun -N ${SLURM_NNODES} --ntasks-per-node 1 -c 56 conda-unpack

set -x

for i in $(seq 1 5); do
    # import MPI automatically does an MPI_Init
    /usr/bin/time srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) \
        -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest \
        python3 -c "import torch"
done
set +x
