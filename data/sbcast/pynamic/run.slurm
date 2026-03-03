#!/bin/bash

#SBATCH -J pynamic
#SBATCH -t 45 
#SBATCH -C nvme

set -e

build_prefix=/lustre/orion/stf243/world-shared/hagertnl/CUG26/benchmark_builds/

source $build_prefix/common_modules.sh

# Needed path for pynamic lib linking
export LD_LIBRARY_PATH=$build_prefix/pynamic/pynamic-pyMPI-2.6a1_util_495_280:$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# Need the MPI4PY Python environment to run the test Python script
set -x

/usr/bin/time sbcast -pf $build_prefix/python-mpi4py/conda_env.tar.gz /mnt/bb/${USER}/conda_env.tar.gz
/usr/bin/time srun -N ${SLURM_NNODES} --ntasks-per-node 1 bash -c "mkdir /mnt/bb/${USER}/conda_env; tar --use-compress-program=pigz -xf /mnt/bb/$USER/conda_env.tar.gz -C /mnt/bb/$USER/conda_env"
conda activate /mnt/bb/${USER}/conda_env
/usr/bin/time srun -N ${SLURM_NNODES} --ntasks-per-node 1 conda-unpack

/usr/bin/time sbcast --send-libs --exclude=NONE -pf $build_prefix/pynamic/pynamic-pyMPI-2.6a1_util_495_280/pynamic-bigexe-mpi4py /mnt/bb/$USER/pynamic-bigexe-mpi4py
# Include the python script that Pynamic's binary calls
/usr/bin/time sbcast -pf $build_prefix/pynamic/pynamic-pyMPI-2.6a1_util_495_280/pynamic_driver_mpi4py.py /mnt/bb/$USER/pynamic_driver_mpi4py.py

set +x

# Need to remove the existing libpython that got sbcast'd, so that it's taken from the conda env
/usr/bin/time srun -N ${SLURM_NNODES} --ntasks-per-node=1 rm /mnt/bb/hagertnl/pynamic-bigexe-mpi4py_libs/libpython3.12.so.1.0

export LD_LIBRARY_PATH=/mnt/bb/$USER/pynamic-bigexe-mpi4py_libs:$CONDA_PREFIX/lib

# libfabric dlopen's several libraries:
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$(pkg-config --variable=libdir libfabric)"

echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

set -x

# cray-mpich/libfabric dlopen's libhsa-runtime64.so and libamdhip64.so (non-versioned), so symlink on each node:
# also, some part of ROCm 6.4.x is dlopen'ing libamd_comgr.so (non-versioned), so symlink it too:
/usr/bin/time srun -N ${SLURM_NNODES} -n ${SLURM_NNODES} --ntasks-per-node=1 --label -D /mnt/bb/$USER/pynamic-bigexe-mpi4py_libs \
    bash -c "if [ -f libhsa-runtime64.so.1 ]; then ln -s libhsa-runtime64.so.1 libhsa-runtime64.so; fi;
    if [ -f libamd_comgr.so.2 ]; then ln -s libamd_comgr.so.2 libamd_comgr.so;
    elif [ -f libamd_comgr.so.3 ]; then ln -s libamd_comgr.so.3 libamd_comgr.so; fi;
    if [ -f libamdhip64.so.5 ]; then ln -s libamdhip64.so.5 libamdhip64.so;
    elif [ -f libamdhip64.so.6 ]; then ln -s libamdhip64.so.6 libamdhip64.so; fi"

ldd /mnt/bb/$USER/pynamic-bigexe-mpi4py
which python3

for i in $(seq 1 5); do
    srun -N ${SLURM_NNODES} -n $((SLURM_NNODES*8)) -t 15 -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest /mnt/bb/$USER/pynamic-bigexe-mpi4py pynamic_driver_mpi4py.py | grep -v 'rank -'
done
set +x

