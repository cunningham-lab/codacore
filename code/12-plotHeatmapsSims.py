
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



n = 200

df = pd.read_csv('./../out/simulations.csv')
# Filter the data
df2 = df[df['n'] == n]
df2['k'] = df2['k'] * 2 # num/den take one each
df2 = df2.round(2)
codacoreB = df2[df2['method'] == 'codacoreB1.0']
codacoreA = df2[df2['method'] == 'codacoreA1.0']
selbal = df2[df2['method'] == 'selbal']
codalasso = df2[df2['method'] == 'codalasso']
amalgam = df2[df2['method'] == 'amalgam']

codacoreB_tpr = pd.pivot_table(codacoreB, values='tpr', index='k', columns='p')
selbal_tpr = pd.pivot_table(selbal, values='tpr', index='k', columns='p')
codalasso_tpr = pd.pivot_table(codalasso, values='tpr', index='k', columns='p')
codacoreB_fpr = pd.pivot_table(codacoreB, values='fpr', index='k', columns='p')
selbal_fpr = pd.pivot_table(selbal, values='fpr', index='k', columns='p')
codalasso_fpr = pd.pivot_table(codalasso, values='fpr', index='k', columns='p')

f, ((ax1, ax2, ax3), (ax4, ax5, ax6)) = plt.subplots(2, 3, sharey=False)
g1 = sns.heatmap(codacoreB_tpr, annot=True, fmt=".2f",
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
g4 = sns.heatmap(codacoreB_fpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(220, 20, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax4)
g4.set_ylabel('Active variables ($k$)')
g4.set_xlabel('Input variables ($p$)')
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
g5.set_xlabel('Input variables ($p$)')
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
g6.set_xlabel('Input variables ($p$)')
g6.set_title('Coda-lasso FPR')
plt.tight_layout()
plt.savefig("../out/figures/balancesSelection.pdf")
plt.show()





codacoreA_tpr = pd.pivot_table(codacoreA, values='tpr', index='k', columns='p')
amalgam_tpr = pd.pivot_table(amalgam, values='tpr', index='k', columns='p')
codacoreA_fpr = pd.pivot_table(codacoreA, values='fpr', index='k', columns='p')
amalgam_fpr = pd.pivot_table(amalgam, values='fpr', index='k', columns='p')


f, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, sharey=False, figsize=(4.35, 4.8))
g1 = sns.heatmap(codacoreA_tpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(20, 220, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax1)
g1.set_ylabel('Active variables ($k$)')
g1.set_xlabel('')
g1.set_title('CoDaCoRe TPR')
g2 = sns.heatmap(
    np.where(amalgam_tpr.isna(), 0, np.nan),
    ax=ax2,
    cbar=False,
    annot=np.full_like(amalgam_tpr, "NA", dtype=object),
    fmt="",
    annot_kws={"size": 10, "va": "center_baseline", "color": "black"},
    cmap=ListedColormap(['none']),
    linewidth=0)
g2 = sns.heatmap(amalgam_tpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(20, 220, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax2)
g2.set_ylabel('')
g2.set_xlabel('')
g2.set_title('Amalgam TPR')
g3 = sns.heatmap(codacoreA_fpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(220, 20, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax3)

g3.set_ylabel('Active variables ($k$)')
g3.set_xlabel('Input variables ($p$)')
g3.set_title('CoDaCoRe FPR')
g4 = sns.heatmap(
    np.where(amalgam_fpr.isna(), 0, np.nan),
    ax=ax4,
    cbar=False,
    annot=np.full_like(amalgam_tpr, "NA", dtype=object),
    fmt="",
    annot_kws={"size": 10, "va": "center_baseline", "color": "black"},
    cmap=ListedColormap(['none']),
    linewidth=0)
g4 = sns.heatmap(amalgam_fpr, annot=True, fmt=".2f",
                 cmap=sns.diverging_palette(220, 20, n=200),
                 vmin=-1, vmax=1, center=0.0,
                 cbar=False, ax=ax4)
g4.set_ylabel('')
g4.set_xlabel('Input variables ($p$)')
g4.set_title('Amalgam FPR')
plt.tight_layout()
plt.savefig("../out/figures/amalgamSelection.pdf")
# plt.show()

