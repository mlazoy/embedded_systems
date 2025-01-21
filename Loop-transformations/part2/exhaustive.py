import sys
import subprocess
import csv

# search space values
L1D = [2, 4, 8, 16, 32, 64]
L1I = [2, 4, 8, 16, 32, 64]
L2 = [128, 256, 512, 1024]
unrolling = [2, 4, 8, 16, 32]

outfile = "exhaustive.csv"

grep_cmd = f"cat m5out/stats.txt | grep system.cpu.numCycles | sed 's/[^0-9]*//g'"


with open(outfile, "w", newline="") as csvfile:
    csv_writer = csv.writer(csvfile)
    csv_writer.writerow(["L1D", "L1I", "L2", "Unrolling", "Cycles"])

    for i in L1D:
        for j in L1I:
            for k in L2:
                for u in unrolling:
                    cmd = f"build/X86/gem5.opt configs/learning_gem5/part1/two_level.py /gem5/tables_UF/tables_uf{u}.exe --l1i_size={j}kB --l1d_size={i}kB --l2_size={k}kB"

                    print("Running: ", cmd)
                    try:
                        subprocess.run(cmd, shell=True, check=True)
                        result = subprocess.run(
                            grep_cmd,
                            shell=True,
                            check=True,
                            capture_output=True,
                            text=True,
                        )
                        cc = result.stdout.strip()
                        print(cc)
                        if cc is not None:
                            csv_writer.writerow(
                                [f"{i}", f"{j}", f"{k}", f"{u}", f"{cc}"]
                            )
                        else:
                            print(f"No cycles found for command: {cmd}")

                    except subprocess.CalledProcessError as e:
                        print(f"Error executing command: {cmd}\n{e}")
