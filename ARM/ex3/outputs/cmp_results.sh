#!/bin/bash

declare -a files1=(
    "rand_str_input_first.txt_concat_out"
    "rand_str_input_first.txt_len_out"
    "rand_str_input_first.txt_sorted_out"
    "rand_str_input_sec.txt_concat_out"
    "rand_str_input_sec.txt_len_out"
    "rand_str_input_sec.txt_sorted_out"
)

declare -a files2=(
    "rand_str_input_first.txt_concat_out_libc"
    "rand_str_input_first.txt_len_out_libc"
    "rand_str_input_first.txt_sorted_out_libc"
    "rand_str_input_sec.txt_concat_out_libc"
    "rand_str_input_sec.txt_len_out_libc"
    "rand_str_input_sec.txt_sorted_out_libc"
)

for i in "${!files1[@]}"; do
    file1=${files1[$i]}
    file2=${files2[$i]}
    
    if cmp -s "$file1" "$file2"; then
        echo "Files $file1 and $file2 are identical."
    else
        echo "Files $file1 and $file2 are not identical."
    fi
done