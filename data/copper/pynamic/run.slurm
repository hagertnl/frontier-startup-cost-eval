#!/bin/bash -x
#SBATCH -A stf243
#SBATCH -J copper_spindle
#SBATCH -o %x-%j.out
#SBATCH -t 00:20:00
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
launch_copper_frontier.sh -d $LOGDIR -v $COPPER_MOUNT_PATH -M 524288000

conda activate $COPPER_MOUNT_PATH/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/python-mpi4py/conda_env

exe=$COPPER_MOUNT_PATH/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/pynamic/pynamic-pyMPI-2.6a1_util_495_280/
export LD_LIBRARY_PATH=${exe}:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${CONDA_PREFIX}/lib:$LD_LIBRARY_PATH
srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 ${exe}/pynamic-bigexe-mpi4py pynamic_driver_mpi4py.py | grep -v 'rank -'
sleep 2s
srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 ${exe}/pynamic-bigexe-mpi4py pynamic_driver_mpi4py.py | grep -v 'rank -'
sleep 2s
srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 ${exe}/pynamic-bigexe-mpi4py pynamic_driver_mpi4py.py | grep -v 'rank -'
sleep 2s
srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 ${exe}/pynamic-bigexe-mpi4py pynamic_driver_mpi4py.py | grep -v 'rank -'
sleep 2s
srun --overlap -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) --ntasks-per-node=8 -c 5 ${exe}/pynamic-bigexe-mpi4py pynamic_driver_mpi4py.py | grep -v 'rank -'
sleep 2s

conda deactivate
stop_copper_frontier.sh -d $LOGDIR -v $COPPER_MOUNT_PATH

