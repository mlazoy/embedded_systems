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
bmh_colors = iter(plt.rcParams["axes.prop_cycle"].by_key()["color"])


data = []
# Load the data & calculate minimums
min_kb = float("inf" )
min_acc_cnt = float("inf")
min_cmb_acc = ()
min_cmb_kd = ()

for file in glob.glob("./results/drr/mem*"):
    regex = re.compile(r"mem_accesses_count_(?P<CL>.*)_CL_(?P<PK>.*)_PK.txt")

    filename = os.path.basename(file)
    match = regex.match(filename)
    cl = match.group("CL")
    pk = match.group("PK")
    access_count = int(open(file).read())

    massif_file = file.replace("mem_accesses_count", "massif_log")
    size = linecache.getline(massif_file, 8)

    massif_data = linecache.getline(massif_file, 9)
    kb = float(massif_data.partition("^")[0])
    if "MB" in size:
        kb *= 1024

    data += [
        {"CL": cl, "PK": pk, "Access Count": access_count, "Peak Memory Usage": kb},
    ]

    if (access_count < min_acc_cnt) :
        min_acc_cnt = access_count
        min_cmb_acc = (cl, pk)
    if (kb < min_kb):
        min_kb = kb 
        min_cmb_kb = (cl, pk)

print("Minimum access count: ", min_cmb_acc, ": ", min_acc_cnt)
print("Mininmum memory peak: ", min_cmb_kb, ": ", min_kb)


df = pd.DataFrame(data)

df.to_csv("./report/drr.csv", index=False)

df["config"] = df["CL"] + " & " + df["PK"]

print(df)


g = sns.catplot(
    kind="bar",
    data=df,
    x="PK",
    y="Access Count",
    col="CL",
    hue="config",
    height=5,
    aspect=0.6,
    palette=bmh_colors,
    legend="brief",
)
# g.set(yscale="log")
g.set_xticklabels(rotation=45)
g.set_titles("CL = {col_name}")
g._legend.set_title("Configuration (CL & PK)")
# Set legend fontsize
for t in g._legend.texts:
    t.set_text(t.get_text())
    t.set_fontsize("small")
plt.subplots_adjust(bottom=0.2, left=0.07)
plt.savefig("./report/drr_access_count.svg")
plt.close(g.fig)

g = sns.catplot(
    kind="bar",
    data=df,
    x="PK",
    y="Peak Memory Usage",
    col="CL",
    hue="config",
    height=5,
    aspect=0.6,
    palette=iter(plt.rcParams["axes.prop_cycle"].by_key()["color"]),
    legend="brief",
)
g.set_xticklabels(rotation=45)
g.set_titles("CL = {col_name}")
g._legend.set_title("Configuration (CL & PK)")
# Set legend fontsize
for t in g._legend.texts:
    t.set_text(t.get_text())
    t.set_fontsize("small")
plt.subplots_adjust(bottom=0.2, left=0.07)
plt.savefig("./report/drr_peak_memory_usage.svg")
plt.close(g.fig)

g = sns.scatterplot(data=df, x="Access Count", y="Peak Memory Usage", hue="config")
g.legend(title="Configuration (CL & PK)")
g.set_title("Access Count vs Peak Memory Usage")
plt.savefig("./report/drr_access_count_vs_peak_memory_usage.svg")