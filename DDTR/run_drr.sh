#!/bin/bash

CL_CONFIGS=(SLL_CL DLL_CL DYN_ARR_CL)
PK_CONFIGS=(SLL_PK DLL_PK DYN_ARR_PK)

BASE_CMD="gcc ./src/DRR/drr.c -pthread -lcdsl -no-pie -L./src/synch_implementations -I./src/synch_implementations"

mkdir -p results/drr

for cl in ${CL_CONFIGS[@]}; do
    for pk in ${PK_CONFIGS[@]}; do
        # Compile
        echo "DDR with $cl and $pk"
        $BASE_CMD -D$cl -D$pk -o drr_${cl}_${pk}.exe

        # Run tasks in the background
        (
            # Run on valgrind lackey
            valgrind --log-file="./results/drr/mem_accesses_log_${cl}_${pk}.txt" --tool=lackey --trace-mem=yes ./drr_${cl}_${pk}.exe

            grep -c 'I\| L' "./results/drr/mem_accesses_log_${cl}_${pk}.txt" >"./results/drr/mem_accesses_count_${cl}_${pk}.txt"
            rm -f "./results/drr/mem_accesses_log_${cl}_${pk}.txt"

            # Run valgrind massif
            valgrind --tool=massif ./drr_${cl}_${pk}.exe &
            MASSIF_PID=$!
            wait $MASSIF_PID
            ms_print massif.out.${MASSIF_PID} >"./results/drr/massif_log_${cl}_${pk}.txt"
            rm -f massif.out.${MASSIF_PID}
        ) &
    done
done

# Wait for all background tasks to complete
wait

rm ./drr_*.exe
