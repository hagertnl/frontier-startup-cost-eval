#!/bin/bash -x
#SBATCH -A stf243
#SBATCH -J copper_spindle
#SBATCH -o %x-%j.out
#SBATCH -t 00:10:00
#SBATCH -p batch
#SBATCH -C nvme

cd $SLURM_SUBMIT_DIR
module load ums ums046 copper
module list
echo $SLURM_JOBID
echo $SLURM_JOB_NUM_NODES
echo $SLURM_JOB_NAME
echo $SLURM_NODELIST

LOGDIR=/lustre/orion/stf243/world-shared/wcastil/Experiments/CUG26/copper_run/logs
cd ${LOGDIR}
PACKAGE_ENV_LOCATION=/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds
source "${PACKAGE_ENV_LOCATION}/common_modules.sh"
COPPER_MOUNT_PATH=/mnt/bb/$USER/copper_mount
launch_copper_frontier.sh -d $LOGDIR -v $COPPER_MOUNT_PATH -M 220000000

conda activate $COPPER_MOUNT_PATH/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/python-mpi4py/conda_env
/usr/bin/time srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 python3 -c "from mpi4py import MPI"
sleep 2s
/usr/bin/time srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 python3 -c "from mpi4py import MPI"
sleep 2s
/usr/bin/time srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 python3 -c "from mpi4py import MPI"
sleep 2s
/usr/bin/time srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 python3 -c "from mpi4py import MPI"
sleep 2s
/usr/bin/time srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 python3 -c "from mpi4py import MPI"
sleep 2s

conda deactivate
stop_copper_frontier.sh -d $LOGDIR -v $COPPER_MOUNT_PATH

