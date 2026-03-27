#!/bin/bash

# This script searches all directories for result files in the naming scheme `slurm-[0-9]+.out`,
# then collates those into a CSV named `setup_times.csv` with rows:
# benchmark,tool,nnodes,jobid,seconds

# Accounting approach: time from job start to the start time of the first workload srun

out_name="setup_times.csv"

echo "benchmark,tool,nnodes,jobid,seconds" > $out_name

for tool in ../data/sbcast ../data/copper; do
    for benchmark in $tool/*; do
        for run_output in $benchmark/*.out; do
            if [[ "$(basename $run_output)" =~ ^.*-[0-9]+\.out$ ]]; then
                filename=$(basename $run_output)
                jobid=$(echo $filename | sed 's/^.*-\([0-9]\+\)\.out/\1/')
                benchmark=$(basename $(dirname $run_output))
                tool=$(basename $(dirname $(dirname $run_output)))
                nnodes=$(sacct -j $jobid -Xn -o nnodes | head -n1 | awk '{print $1}')

                job_start_time=$(sacct -Xn -j $jobid -o start | awk '{print $1}')
                workload_start_time=$(sacct -n -j $jobid -o jobid,start,ntasks | tail -n +3 | awk "\$3 == $((nnodes*8)) { print \$0 }" | head -n1 | awk '{print $2}')
                echo "For jobid=$jobid, have job_start_time=$job_start_time, workload_start_time=$workload_start_time"

                # Convert each date to epoch seconds
                job_start_timestamp=$(date -d "$job_start_time" +%s)
                workload_start_timestamp=$(date -d "$workload_start_time" +%s)

                setup_time=$((workload_start_timestamp - job_start_timestamp))

                echo "$benchmark,$tool,$nnodes,$jobid,$setup_time" >> $out_name
            fi
        done
    done
done
