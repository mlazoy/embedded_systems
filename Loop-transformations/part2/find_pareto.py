"""
@Authors: Maria Lazou, Stavros Avramidis
@Date: 11/11/2024
"""

from paretoset import paretoset
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

df = pd.read_csv("exhaustive.csv")
df["totalMemoryKB"] = df["L1D"] + df["L1I"] + df["L2"]
result_df = df[["totalMemoryKB", "Cycles"]].rename(columns={"Cycles": "Latency"})
print(result_df.head())

mask = paretoset(result_df, sense=["min", "min"])
# apply it on initial df
optimal = df[mask]
print(optimal)
optimal.to_csv("optimal_results.csv", index=False)

df["Pareto_optimal"] = mask

# Setup seaborn
sns.set_theme(style="whitegrid")
plt.style.use("bmh")
plt.rcParams["font.family"] = "Libertinus Serif"
plt.rcParams["font.size"] = 12
bmh_colors = plt.rcParams["axes.prop_cycle"].by_key()["color"]

# Trick seaborn to bring pareto optimal points to the front
g = sns.scatterplot(
    data=df[df["Pareto_optimal"] == False],
    x="totalMemoryKB",
    y="Cycles",
    hue="Pareto_optimal",
    palette={True: bmh_colors[1], False: "darkgray"},
)
sns.scatterplot(
    data=df[df["Pareto_optimal"] == True],
    x="totalMemoryKB",
    y="Cycles",
    hue="Pareto_optimal",
    palette={True: bmh_colors[1], False: "darkgray"},
)
g.set_title("Pareto Optimal Points - Total Memory vs. Latency")
g.set_xlabel("Total Memory (KB)")
g.set_ylabel("Latency (Cycles)")
g.legend(title="Pareto Optimal")
plt.savefig("pareto_optimal.svg")
