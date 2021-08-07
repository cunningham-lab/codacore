
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import pandas as pd
import numpy as np
import seaborn as sns
from matplotlib.colors import ListedColormap

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

matplotlib.rc('xtick', labelsize=9)
matplotlib.rc('ytick', labelsize=9)
font = {'weight' : 'normal',
        'size'   : 9}
matplotlib.rc('font', **font)




codacore = pd.read_csv('./../out/resCodacore.csv')
selbal = pd.read_csv('./../out/resSelbal.csv')
codalasso = pd.read_csv('./../out/resCodalasso.csv')

codacore_tpr = pd.pivot_table(codacore, values='tpr', index='ntrue', columns='nfalse')
selbal_tpr = pd.pivot_table(selbal, values='tpr', index='ntrue', columns='nfalse')
codalasso_tpr = pd.pivot_table(codalasso, values='tpr', index='ntrue', columns='nfalse')

codacore_fpr = pd.pivot_table(codacore, values='fpr', index='ntrue', columns='nfalse')
selbal_fpr = pd.pivot_table(selbal, values='fpr', index='ntrue', columns='nfalse')
codalasso_fpr = pd.pivot_table(codalasso, values='fpr', index='ntrue', columns='nfalse')


f, ((ax1, ax2, ax3), (ax4, ax5, ax6)) = plt.subplots(2, 3, sharey=False)
g1 = sns.heatmap(codacore_tpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(20, 220, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax1)
g1.set_ylabel('Active variables ($k$)')
g1.set_xlabel('')
g1.set_title('CoDaCoRe TPR')
g2 = sns.heatmap(
    np.where(selbal_tpr.isna(), 0, np.nan),
    ax=ax2,
    cbar=False,
    annot=np.full_like(selbal_tpr, "NA", dtype=object),
    fmt="",
    annot_kws={"size": 10, "va": "center_baseline", "color": "black"},
    cmap=ListedColormap(['none']),
    linewidth=0)
g2 = sns.heatmap(selbal_tpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(20, 220, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax2)
g2.set_ylabel('')
g2.set_xlabel('')
g2.set_title('Selbal TPR')
g3 = sns.heatmap(
    np.where(codalasso_tpr.isna(), 0, np.nan),
    ax=ax3,
    cbar=False,
    annot=np.full_like(codalasso_tpr, "NA", dtype=object),
    fmt="",
    annot_kws={"size": 10, "va": "center_baseline", "color": "black"},
    cmap=ListedColormap(['none']),
    linewidth=0)
g3 = sns.heatmap(codalasso_tpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(20, 220, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax3)
g3.set_ylabel('')
g3.set_xlabel('')
g3.set_title('Coda-lasso TPR')
g4 = sns.heatmap(codacore_fpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(220, 20, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax4)
g4.set_ylabel('Active variables ($k$)')
g4.set_xlabel('Inactive variables ($\\tilde k$)')
g4.set_title('CoDaCoRe FPR')
g5 = sns.heatmap(
    np.where(selbal_fpr.isna(), 0, np.nan),
    ax=ax5,
    cbar=False,
    annot=np.full_like(selbal_fpr, "NA", dtype=object),
    fmt="",
    annot_kws={"size": 10, "va": "center_baseline", "color": "black"},
    cmap=ListedColormap(['none']),
    linewidth=0)
g5 = sns.heatmap(selbal_fpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(220, 20, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax5)
g5.set_ylabel('')
g5.set_xlabel('Inactive variables ($\\tilde k$)')
g5.set_title('Selbal FPR')
g6 = sns.heatmap(
    np.where(codalasso_tpr.isna(), 0, np.nan),
    ax=ax6,
    cbar=False,
    annot=np.full_like(codalasso_fpr, "NA", dtype=object),
    fmt="",
    annot_kws={"size": 10, "va": "center_baseline", "color": "black"},
    cmap=ListedColormap(['none']),
    linewidth=0)
g6 = sns.heatmap(codalasso_fpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(220, 20, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax6)
g6.set_ylabel('')
g6.set_xlabel('Inactive variables ($\\tilde k$)')
g6.set_title('Coda-lasso FPR')
plt.tight_layout()
plt.savefig("../out/figures/balancesSelectionSusin.pdf")
plt.show()
