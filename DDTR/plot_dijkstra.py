import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import glob
import os
import re
import linecache

# Change the working directory to the location of the script
abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)


# Setup seaborn
sns.set_theme(style="whitegrid")
plt.style.use("bmh")
plt.rcParams["font.family"] = "Libertinus Serif"
plt.rcParams["font.size"] = 12
bmh_colors = plt.rcParams["axes.prop_cycle"].by_key()["color"]


data = []
# Load the data & calculate minimums
min_kb = float("inf" )
min_acc_cnt = float("inf")
min_cmb_acc = ()
min_cmb_kd = ()
for file in glob.glob("./results/dijkstra/mem*"):
    regex = re.compile(r"mem_accesses_count_(?P<CONFIG>.*).txt")

    filename = os.path.basename(file)
    match = regex.match(filename)
    config = match.group("CONFIG")
    access_count = int(open(file).read())

    massif_file = file.replace("mem_accesses_count", "massif_log")
    size = linecache.getline(massif_file, 8)

    massif_data = linecache.getline(massif_file, 9)
    kb = float(massif_data.partition("^")[0])
    if "MB" in size:
        kb *= 1024

    data += [
        {
            "Configuration": config,
            "Access Count": access_count,
            "Peak Memory Usage": kb,
        },
    ]

    if (access_count < min_acc_cnt) :
        min_acc_cnt = access_count
        min_cmb_acc = config
    if (kb < min_kb and config != "Original"):
        min_kb = kb 
        min_cmb_kb = config

print("Minimum access count: ", min_cmb_acc, ": ", min_acc_cnt)
print("Mininmum memory peak: ", min_cmb_kb, ": ", min_kb)


df = pd.DataFrame(data)
df.to_csv("./report/dijkstra.csv", index=False)

df["Configuration"] = pd.Categorical(
    df["Configuration"],
    categories=["Original", "SLL", "DLL", "DYN_ARR"],
    ordered=True,
)

print(df)


g = sns.barplot(
    data=df,
    x="Configuration",
    y="Access Count",
    palette=bmh_colors,
    hue="Configuration",
    legend=False,
)
g.set_title("Access Count for each configuration")
plt.savefig("./report/dijkstra_access_count.svg")
plt.close()

g = sns.barplot(
    data=df,
    x="Configuration",
    y="Peak Memory Usage",
    palette=bmh_colors,
    hue="Configuration",
)
g.set_title("Peak Memory Usage for each configuration")
plt.savefig("./report/dijkstra_peak_memory_usage.svg")
plt.close()

g = sns.scatterplot(
    data=df,
    x="Access Count",
    y="Peak Memory Usage",
    hue="Configuration",
    palette=bmh_colors,
)
g.set_title("Access Count vs Peak Memory Usage")
plt.savefig("./report/dijkstra_access_count_vs_peak_memory_usage.svg")
