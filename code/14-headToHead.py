
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

matplotlib.rc('xtick', labelsize=13)
matplotlib.rc('ytick', labelsize=13)
font = {'weight' : 'normal',
        'size'   : 12}
matplotlib.rc('font', **font)



methods = {
    "codacoreB1.0SE": "CoDaCoRe (defaults)",
    "selbal": "Selbal",
    "PRA": "Pairwise log-ratios",
    "codalasso": "Coda-lasso ",
    "amalgamSLR": "Amalgam",
    "deepcodaSE": "DeepCoDA",
    "codacoreB0.0SE": "CoDaCoRe ($\\lambda=0$)",
}


out_vars = {
    'runTime': 'Runtime',
    'activeVars': 'Sparsity',
    'accTe': 'Out-of-sample accuracy',
    'aucTe': 'Out-of-sample AUC',
    'f1Te': 'Out-of-sample F1 score',
}

rawRes = pd.read_csv('./../out/quinn2020.csv')

for out_var in out_vars:
    df1 = rawRes.copy()

    df1 = df1.fillna(0)
    if out_var in ['runTime', 'activeVars']:
        df1[out_var] = -df1[out_var] # less is better

    heatmap_df = pd.DataFrame(np.zeros([len(methods), len(methods)]), columns=list(methods.values()),
                              index=list(methods.values()))
    for method1 in methods:
        for method2 in methods:
            temp1 = df1[df1['method'] == method1]
            temp2 = df1[df1['method'] == method2]
            temp3 = pd.merge(temp1, temp2, left_on=['seed', 'dataIdx'], right_on=['seed', 'dataIdx'], how='inner')
            v1 = out_var + '_x'
            v2 = out_var + '_y'
            heatmap_df.loc[methods[method1], methods[method2]] = np.mean(temp3[v1] > temp3[v2]) + 0.5 * np.mean(temp3[v1] == temp3[v2])

    sns.heatmap(heatmap_df, annot=True, fmt=".2f",
                     cmap=sns.diverging_palette(20, 220, n=200),
                     vmin=0, vmax=1, center=0.5,
                     cbar=False)
    plt.tight_layout()
    plt.title(out_vars[out_var] + ' (win rate)')
    plt.tight_layout()
    out_path = f'./../out/figures/winRate{out_var}.pdf'
    plt.savefig(out_path)
    plt.show()








