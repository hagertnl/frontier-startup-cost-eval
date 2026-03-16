#!/bin/bash

# This script searches all directories for result files in the naming scheme `slurm-[0-9]+.out`,
# then collates those into a CSV named `sbcast_times.csv` with rows:
# benchmark,tool,nnodes,jobid,seconds

# Accounting approach: find all /usr/bin/time outputs and sum them together,
# then subtract all from a benchmarking srun

# This is only for sbcast because Copper's /usr/bin/time calls are not representative of the overhead

out_name="sbcast_times.csv"

echo "benchmark,tool,nnodes,jobid,seconds" > $out_name

get_benchmark_time() {
    total_time=0
    if [ ! "$1" == "pynamic" ]; then
        for elapsed_time in $(grep -A5 'ntasks-per-node=8' $2 | grep 'maxresident' | awk '{print $3}' | cut -d'e' -f1); do
            seconds=$(python3 -c "s='${elapsed_time}'; print(int(s.split(':')[0])*60+float(s.split(':')[1]))")
            total_time=$(echo "$total_time + $seconds" | bc -l)
        done
        echo $total_time
    else
        echo "0.0"
    fi
}

for tool in ../data/sbcast; do
    for benchmark in $tool/*; do
        for run_output in $benchmark/*.out; do
            if [[ "$(basename $run_output)" =~ ^.*-[0-9]+\.out$ ]]; then
                filename=$(basename $run_output)
                jobid=$(echo $filename | sed 's/^.*-\([0-9]\+\)\.out/\1/')
                benchmark=$(basename $(dirname $run_output))
                tool=$(basename $(dirname $(dirname $run_output)))
                nnodes=$(sacct -j $jobid -Xn -o nnodes | head -n1 | awk '{print $1}')

                setup_time=0
                benchmark_time=$(get_benchmark_time $benchmark $run_output)

                for t in $(grep 'maxresident' $run_output | awk '{print $3}' | cut -d'e' -f1); do
                    s=$(python3 -c "s='${t}'; print(int(s.split(':')[0])*60+float(s.split(':')[1]))")
                    setup_time=$(echo "$setup_time + $s" | bc -l)
                done
                setup_time=$(echo "$setup_time - $benchmark_time" | bc -l)
                echo "$benchmark,$tool,$nnodes,$jobid,$setup_time" >> $out_name
            fi
        done
    done
done
