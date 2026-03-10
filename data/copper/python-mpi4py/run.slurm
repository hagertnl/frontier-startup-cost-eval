#!/bin/bash -x
#SBATCH -A stf008
#SBATCH -J mpi4py_cpr
#SBATCH -o %x-%j.out
#SBATCH -t 00:15:00
#SBATCH -p batch
#SBATCH -N 512
#SBATCH --network=single_node_vni,job_vni,def_tles=0
#SBATCH --threads-per-core=2

# All benchmarks use this set of modules:
source /lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/common_modules.sh
module load libfabric/1.22.0
module load ums ums046 copper

# if script is being run with ./common_modules.sh (instead of sourced), print the module set:
if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
    echo "This script should be sourced! When it is not, it prints out the resulting module set:"
    module list
fi

# Lustre base for this project
LOGDIR=/lustre/orion/stf008/proj-shared/hvac/copper-cug/copper_logs

launch_copper.sh -d $LOGDIR

conda activate /tmp/$USER/copper/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/python-mpi4py/conda_env

exe=/tmp/$USER/copper/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/pynamic/pynamic-pyMPI-2.6a1_util_495_280/

set -x

for i in $(seq 1 5); do
    # import MPI automatically does an MPI_Init
    /usr/bin/time srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) \
        -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest \
        --cpus-per-task=1 --threads-per-core=1 --network=single_node_vni,job_vni \
        python3 -c "from mpi4py import MPI"
done
set +x

  stop_copper.sh -d $LOGDIR
