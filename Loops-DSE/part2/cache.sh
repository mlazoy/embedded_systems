#!/bin/bash

outfile="cache.txt"

rm -f $outfile
touch $outfile
echo -e "L1D Size(KB)	system.cpu.numCycles " >>$outfile
for i in 2 4 8 16 32 64; do
    build/X86/gem5.opt configs/learning_gem5/part1/two_level.py /gem5/tables_UF/tables.exe --l1i_size=8kB --l1d_size=${i}kB --l2_size=128kB
    echo -ne "${i}:\t\t\t" >>$outfile
    cat m5out/stats.txt | grep system.cpu.numCycles | sed 's/[^0-9]*//g' >>$outfile
done
