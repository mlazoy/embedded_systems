#!/bin/bash

for bits in 3 4 5 6 7 8 9 10; do
    echo "Compiling main.cpp for BITS=$bits"
    g++ -DBITS=$bits -O2 -I/opt/Xilinx/SDx/2016.4/Vivado_HLS/include -ITanh/ main.cpp network.cpp -o a.out
    
    ./a.out data.txt
    mv output.txt "output_bits${bits}.txt"

    echo "Output for BITS=$bits saved to output_bits${bits}.txt"
done