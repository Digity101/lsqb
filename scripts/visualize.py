# %%
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import math

#%%
df = pd.read_csv("../results/results.csv", sep='\t', names=["Name", "Threads", "SF", "Query", "Time", "Result"])
df

# %%
df_agg = df.groupby(by=["Query", "Name"])["Time"].mean().unstack()
df_agg.index = df_agg.index.get_level_values('Query')
df_agg


# %%
ax = df_agg.plot.bar()
ax.legend(title=None)
ax.set_title("LSQB SF=0.1 16MB Memory Limit Mean Running Time Of 10 Runs")
ax
# %%
