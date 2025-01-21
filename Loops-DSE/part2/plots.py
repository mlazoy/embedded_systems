"""
@Authors: Maria Lazou, Stavros Avramidis
@Date: 5/11/2024
"""

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import re
import seaborn as sns

f_unroll = "unrolling.txt"
f_cache = "cache.txt"

unroll_vals = {}
cache_vals = {}

with open(f_unroll, "r") as f1:
    f1.readline()  # skip header
    for row in f1:
        unrolling_factor = int(row.split(":")[0])
        cc = int(row.split(":")[1])
        unroll_vals[unrolling_factor] = cc


with open(f_cache) as f2:
    f2.readline()  # skip header
    for row in f2:
        l1d = int(row.split(":")[0])
        cc = int(row.split(":")[1])
        cache_vals[l1d] = cc

# df1 = pd.load

# Setup seaborn
sns.set_theme(style="whitegrid")
plt.style.use("bmh")
plt.rcParams["font.family"] = "Libertinus Serif"
plt.rcParams["font.size"] = 12
bmh_colors = iter(plt.rcParams["axes.prop_cycle"].by_key()["color"])

df_unroll = pd.DataFrame(
    unroll_vals.items(), columns=["Unrolling Factor", "CPU Cycles"]
)
df_cache = pd.DataFrame(cache_vals.items(), columns=["L1 Data Size (KB)", "CPU Cycles"])

print(df_unroll)
print(df_cache)

# Make unrolling plot
g = sns.lineplot(x="Unrolling Factor", y="CPU Cycles", data=df_unroll, marker="o")
g.set_xticks(df_unroll["Unrolling Factor"])
plt.title("CPU Cycles vs Unrolling Factor")
plt.savefig("unrolling.svg")
plt.close()

# Make cache plot
g = sns.lineplot(x="L1 Data Size (KB)", y="CPU Cycles", data=df_cache, marker="o")
g.set_xticks(df_cache["L1 Data Size (KB)"])
plt.title("CPU Cycles vs L1 Data Size")
plt.savefig("cache.svg")
