
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import pandas as pd
import numpy as np
import seaborn as sns
from matplotlib.colors import ListedColormap
import statsmodels.api as sm

###################################
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
        'size'   : 12}
matplotlib.rc('font', **font)


df = pd.read_csv('./../out/quinn2020.csv')

out_var = 'accTe'

methods = {
    "codacoreB1.0SE": "CoDaCoRe (ours) ",
    "selbal": "Selbal",
    "PRA": "Pairwise log-ratios",
    "codalasso": "Coda-lasso ",
    "amalgamSLR": "Amalgam",
    "deepcodaSE": "DeepCoDA",
}

dataset_attr = df[['dataIdx', 'inputDim', 'numObs', 'accBL']]
dataset_attr = pd.pivot_table(dataset_attr, values=['inputDim', 'numObs', 'accBL'], index='dataIdx')
temp = pd.pivot_table(df, values='accTe', index=['dataIdx'], columns='method')
dataset_attr['StN'] = temp['rawRF'] - dataset_attr['accBL']


df2 = df[df['method'].isin(methods)]
df2 = pd.pivot_table(df2, values=out_var, index='dataIdx', columns='method')


ranks = df2.rank(axis=1, ascending=False)



f, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, sharey=False, figsize=(6, 6))


ax1.scatter(dataset_attr['numObs'], ranks['codacoreB1.0SE'], facecolors='none', edgecolors='tab:blue')
ax1.set_xlabel('Number of observations ($n$)')
ax1.set_ylabel('Rank')
ax1.set_xticks([0, 500, 1000, 1500, 2000])
ax1.set_xlim([0, 2200])
ax1.set_ylim(0.7, 6.3)
z = np.polyfit(dataset_attr['numObs'], ranks['codacoreB1.0SE'], 1)
p = np.poly1d(z)
ax1.plot(dataset_attr['numObs'],p(dataset_attr['numObs']), color='lightblue', linestyle='solid', linewidth=1)

ax2.scatter(dataset_attr['inputDim'], ranks['codacoreB1.0SE'], facecolors='none', edgecolors='tab:blue')
ax2.set_xlabel('Number of variables ($p$)')
ax2.set_ylim(0.7, 6.3)
z = np.polyfit(dataset_attr['inputDim'], ranks['codacoreB1.0SE'], 1)
p = np.poly1d(z)
ax2.plot(dataset_attr['inputDim'],p(dataset_attr['inputDim']), color='lightblue', linestyle='solid', linewidth=1)

ax3.scatter(dataset_attr['accBL'], ranks['codacoreB1.0SE'], facecolors='none', edgecolors='tab:blue')
ax3.set_xlabel('Class imbalance')
ax3.set_ylabel('Rank')
ax3.set_xticks([0.5, 0.6, 0.7, 0.8, 0.9, 1.0])
ax3.set_ylim(0.7, 6.3)
z = np.polyfit(dataset_attr['accBL'], ranks['codacoreB1.0SE'], 1)
p = np.poly1d(z)
ax3.plot(dataset_attr['accBL'],p(dataset_attr['accBL']), color='lightblue', linestyle='solid', linewidth=1)


ax4.scatter(dataset_attr['StN'], ranks['codacoreB1.0SE'], facecolors='none', edgecolors='tab:blue')
ax4.set_xlabel('Signal-to-noise')
ax4.set_ylim(0.7, 6.3)
ax4.set_xticks([0.0, 0.2, 0.4, 0.6, 0.8, 1.0])
z = np.polyfit(dataset_attr['StN'], ranks['codacoreB1.0SE'], 1)
p = np.poly1d(z)
ax4.plot(dataset_attr['StN'],p(dataset_attr['StN']), color='lightblue', linestyle='solid', linewidth=1)

plt.suptitle('CoDaCoRe Accuracy over 25 datasets')
plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig("../out/figures/ablations.pdf")
plt.show()



