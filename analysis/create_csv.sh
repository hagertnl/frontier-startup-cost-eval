#!/bin/bash

# This script searches all directories for result files in the naming scheme `slurm-[0-9]+.out`,
# then collates those into a CSV named `benchmark_times.csv` with rows:
# benchmark,tool,nnodes,jobid,iteration,seconds

# Output of benchmark runs should look like:
#+ /usr/bin/time srun -N 512 -n 4096 -c 7 --ntasks-per-node=8 --gpus-per-node=8 --gpu-bind=closest python3 -c 'from mpi4py import MPI'
#srun: Step created for StepId=4142540.4
#0.10user 0.15system 0:17.46elapsed 1%CPU (0avgtext+0avgdata 20480maxresident)k
#0inputs+0outputs (0major+5162minor)pagefaults 0swaps
#+ set +x

out_name="benchmark_times.csv"

echo "benchmark,tool,nnodes,jobid,iteration,seconds" > $out_name

for tool in ../data/*; do
    for benchmark in $tool/*; do
        for run_output in $benchmark/slurm-*.out; do
            if [[ "$(basename $run_output)" =~ ^slurm-[0-9]+\.out$ ]]; then
                filename=$(basename $run_output)
                jobid=$(echo $filename | cut -d'-' -f2 | cut -d'.' -f1)
                benchmark=$(basename $(dirname $run_output))
                tool=$(basename $(dirname $(dirname $run_output)))
                nnodes=$(sacct -j $jobid -Xn -o nnodes | head -n1 | awk '{print $1}')

                iteration=1
                for elapsed_time in $(grep 'maxresident' $run_output | awk '{print $3}' | cut -d'e' -f1); do
                    seconds=$(python3 -c "s='${elapsed_time}'; print(int(s.split(':')[0])*60+float(s.split(':')[1]))")
                    echo "$benchmark,$tool,$nnodes,$jobid,$iteration,$seconds" >> $out_name
                    iteration=$((iteration+1))
                done
            fi
        done
    done
done
