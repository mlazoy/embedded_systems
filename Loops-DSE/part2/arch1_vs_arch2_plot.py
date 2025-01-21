"""
@Authors: Maria Lazou, Stavros Avramidis
@Date: 5/11/2024
"""

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


data = {"Architecture 1": 858895958, "Architecture 2": 59723234}

df = pd.DataFrame(data.items(), columns=["Architecture", "CPU Cycles"])

# Setup seaborn
sns.set_theme(style="whitegrid")
plt.style.use("bmh")
plt.rcParams["font.family"] = "Libertinus Serif"
plt.rcParams["font.size"] = 12
bmh_colors = iter(plt.rcParams["axes.prop_cycle"].by_key()["color"])

# Create the plot
g = sns.barplot(
    x="Architecture",
    y="CPU Cycles",
    data=df,
    palette=[next(bmh_colors), next(bmh_colors)],
)
g.set_title("Amount of CPU Cycles for the two architectures")
g.set_ylabel("# of CPU Cycles")
g.set_xlabel("Architecture")
plt.savefig("arch1_vs_arch2_plot.svg")
