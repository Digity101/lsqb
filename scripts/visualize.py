# %%
import pandas as pd

#%%
df = pd.read_csv("../results/results.csv", sep='\t', names=["Name", "Threads", "SF", "Query", "Time", "Result"])
df

# %%
df_std = df.groupby(by=["Query", "Name"])["Time"].std().unstack()
df_std.index = df_std.index.get_level_values('Query')
df_std

# %%
df_agg = df.groupby(by=["Query", "Name"])["Time"].median().unstack()
df_agg.index = df_agg.index.get_level_values('Query')
df_agg


# %%
ax = df_agg.plot.bar(yerr=df_std)
ax.legend(title=None)
ax.set_title("LSQB SF=0.1 Memory=64MB Median Running Time Of 10 Runs")
ax
# %%
