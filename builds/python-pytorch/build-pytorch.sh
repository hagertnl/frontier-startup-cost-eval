#!/bin/bash

set -e

source ../common_modules.sh

rm -rf ./conda_env ./conda_env.tar.gz

conda create --prefix=${PWD}/conda_env python=3.12
conda activate ${PWD}/conda_env

pip install torch==2.8.0 torchvision==0.23.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/rocm6.4

# Pack for sbcast
conda install conda-pack -c conda-forge
conda pack --format tar.gz --n-threads -1 --prefix ${PWD}/conda_env --output ${PWD}/conda_env.tar.gz

