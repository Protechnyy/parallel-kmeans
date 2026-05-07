#!/bin/bash
# Experiment script for K-Means parallel algorithm
# Measures speedup, efficiency, and cost

set -e

cd "$(dirname "$0")"

# Compile both versions
echo "Compiling..."
mpicxx -O2 -std=c++17 -o kmeans_serial kmeans_serial.cpp
mpicxx -O2 -std=c++17 -o kmeans_mpi kmeans_mpi.cpp

# Experiment parameters
K=8
d=16
max_iter=20
N_values=(10000 50000 100000 500000)
P_values=(1 2 4 8)

RESULT_FILE="results/experiment_results.csv"
echo "N,d,K,max_iter,P,time_ms,speedup,efficiency,cost" > "$RESULT_FILE"

for N in "${N_values[@]}"; do
    echo "========================================"
    echo "Running experiments for N=$N"
    echo "========================================"

    # Run serial version for baseline
    echo "  [Serial] N=$N ..."
    serial_output=$(./kmeans_serial "$N" "$d" "$K" "$max_iter")
    serial_time=$(echo "$serial_output" | grep -o 'time_ms=[0-9.]*' | cut -d= -f2)
    echo "    Serial time: ${serial_time} ms"

    # Run parallel versions
    for P in "${P_values[@]}"; do
        echo "  [MPI] P=$P N=$N ..."
        mpi_output=$(mpirun --oversubscribe -np "$P" ./kmeans_mpi "$N" "$d" "$K" "$max_iter")
        mpi_time=$(echo "$mpi_output" | grep -o 'time_ms=[0-9.]*' | cut -d= -f2)

        # Calculate metrics
        speedup=$(echo "scale=4; $serial_time / $mpi_time" | bc)
        efficiency=$(echo "scale=4; $speedup / $P" | bc)
        cost=$(echo "scale=4; $mpi_time * $P" | bc)

        echo "    Time: ${mpi_time} ms | Speedup: $speedup | Efficiency: $efficiency | Cost: $cost"
        echo "$N,$d,$K,$max_iter,$P,$mpi_time,$speedup,$efficiency,$cost" >> "$RESULT_FILE"
    done
    echo ""
done

echo "========================================"
echo "All experiments completed."
echo "Results saved to: $RESULT_FILE"
echo "========================================"
