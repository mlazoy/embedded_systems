#!/bin/bash

CONFIGS=(SLL DLL DYN_ARR)

BASE_CMD="gcc ./src/dijkstra/dijkstra_cdsl.c -pthread -lcdsl -no-pie -L./src/synch_implementations -I./src/synch_implementations"

mkdir -p results/dijkstra

for config in ${CONFIGS[@]}; do
    (
        # Compile
        echo "Dijkstra with $config"
        $BASE_CMD -D$config -o dijkstra_${config}.exe

        # Run on valgrind lackey
        valgrind --log-file="./results/dijkstra/mem_accesses_log_${config}.txt" --tool=lackey --trace-mem=yes ./dijkstra_${config}.exe ./src/dijkstra/input.dat
        grep -c 'I\| L' "./results/dijkstra/mem_accesses_log_${config}.txt" >"./results/dijkstra/mem_accesses_count_${config}.txt"
        rm -f "./results/dijkstra/mem_accesses_log_${config}.txt"

        # Run valgrind massif
        valgrind --tool=massif ./dijkstra_${config}.exe ./src/dijkstra/input.dat &
        MASSIF_PID=$!
        wait $MASSIF_PID
        ms_print massif.out.${MASSIF_PID} >"./results/dijkstra/massif_log_${config}.txt"
        rm -f massif.out.${MASSIF_PID}
    ) &
done

# Also run the plain dijkstra
(

    echo "Dijkstra Plain"
    gcc ./src/dijkstra/dijkstra.c -pthread -o dijkstra.exe
    valgrind --log-file="./results/dijkstra/mem_accesses_log_original.txt" --tool=lackey --trace-mem=yes ./dijkstra ./src/dijkstra/input.dat

    grep -c 'I\| L' "./results/dijkstra/mem_accesses_log_original.txt" >"./results/dijkstra/mem_accesses_count_original.txt"
    rm -f "./results/dijkstra/mem_accesses_log_original.txt"

    valgrind --tool=massif ./dijkstra ./src/dijkstra/input.dat &
    MASSIF_PID=$!
    wait $MASSIF_PID
    ms_print massif.out.${MASSIF_PID} >"./results/dijkstra/massif_log_original.txt"
    rm -f massif.out.${MASSIF_PID}
) &

wait

rm ./dijkstra*.exe
