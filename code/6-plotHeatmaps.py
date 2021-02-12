
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import pandas as pd
import numpy as np

###################################
# Required to avoid type3 fonts that break ICML submission pdf
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
###################################

###################################
# Storing colors here
blue = "#377eb8"
purple = "#984ea3"
orange = "#ff7f00"
brown = "#a65628"
pink = "#f781bf"
grey = "#999999"
# green = "#4daf4a"
# red = "#e41a1c"
# yellow = "#ffff33"
####################################

matplotlib.rc('xtick', labelsize=12)
matplotlib.rc('ytick', labelsize=12)
font = {'weight' : 'normal',
        'size'   : 14}
matplotlib.rc('font', **font)


xVar = 'aucTe'
yVar = 'runTime'
methods = {
    'PRA': {'color': brown, 'legend': 'Pairwise LRs', 'marker': 'v'},
    'selbal': {'color': blue, 'legend': 'Selbal', 'marker': 's'},
    'codaboostB0.5SE': {'color': purple, 'legend': 'CoDaCoRe (ours)', 'marker': 'o'},
    'codalasso': {'color': pink, 'legend': 'Coda-lasso', 'marker': 'P'},
    'amalgamSLR': {'color': orange, 'legend': 'Amalgam', 'marker': 'p'},
    # 'deepcodaSE': {'color': grey, 'legend': 'DeepCoDA', 'marker': 'D'},
}

colors = [methods[i]['color'] for i in methods]
markers = [methods[i]['marker'] for i in methods]
legend_names = [methods[i]['legend'] for i in methods]
#
# methods = {
#     'PRA': brown,
#     'selbal': blue,
#     'amalgamSLR': orange,
#     'codaboostB0.0SE': purple,
# }




bala = pd.read_csv('./../out/heatmapBalance.csv')
amal = pd.read_csv('./../out/heatmapAmalgamation.csv')
bala = bala.iloc[::-1, :]
amal = amal.iloc[::-1, :]

bala.iloc[:, 0] = bala.iloc[:, 0].str.split('_').str[2]
amal.iloc[:, 0] = amal.iloc[:, 0].str.split('_').str[2]


fig = plt.figure(figsize=(6, 8.4))

# Adds subplot on position 1
ax1 = fig.add_subplot(211)
# Adds subplot on position 2
ax2 = fig.add_subplot(212)

# fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True)
# fig.figsize()
# ax1.plot(x, y)
# ax1.set_title('Sharing Y axis')
# ax2.scatter(x, y)


color_map = matplotlib.colors.ListedColormap(['#F0F337', '#E3DAC3', '#F9B347'])
color_map = matplotlib.colors.ListedColormap(['#F9B347', '#E3DAC3', '#46bee3'])

ax1.imshow(bala.iloc[:, 1:11], aspect='auto', cmap=color_map)
ax2.imshow(amal.iloc[:, 1:11], aspect='auto', cmap=color_map)

# Add lines to separate numerator from denominator
# ax1.axhline((bala.sum(axis=1)>0).sum() - 0.5, color='grey')
# ax2.axhline((amal.sum(axis=1)>0).sum() - 0.5, color='grey')

# plt.xticks(ticks=np.arange(0, 10), labels=np.arange(1, 11))
ax1.set_yticks(ticks=np.arange(0, bala.shape[0]))
ax1.set_yticklabels(labels=bala.iloc[::-1,0])
ax2.set_yticks(ticks=np.arange(0, amal.shape[0]))
ax2.set_yticklabels(labels=amal.iloc[::-1,0])
ax1.set_xticks(ticks=np.arange(0, 10))
ax1.set_xticklabels(labels=np.arange(1,11))
ax2.set_xticks(ticks=np.arange(0, 10))
ax2.set_xticklabels(labels=np.arange(1,11))
ax1.set_title('CoDaCoRe - Balances')
ax2.set_title('CoDaCoRe - Amalgamations')
ax2.set_xlabel('Independent 80% training set splits')

# Remove ticks but keep labels
ax1.tick_params(axis=u'both', which=u'both',length=0)
ax2.tick_params(axis=u'both', which=u'both',length=0)

# plt.yticks(ticks=np.arange(0, bala.shape[0]), labels=df.iloc[::-1,0])
# plt.axis('equal')
# plt.figaspect(1)

plt.tight_layout()
plt.savefig("../manuscript/figures/heatmap.pdf")
plt.savefig("../out/figures/heatmap.pdf")

plt.show()