
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
# plt.ylim(-45,15)


xVar = 'accTe'
yVar = 'runTime'
methods = {
    'codacoreB1.0SE': {'color': purple, 'legend': 'CoDaCoRe (ours)', 'marker': 'o'},
    'selbal': {'color': blue, 'legend': 'Selbal', 'marker': 's'},
    'PRA': {'color': pink, 'legend': 'Pairwise log-ratios', 'marker': 'v'},
    'codalasso': {'color': orange, 'legend': 'Coda-lasso', 'marker': 'P'},
    'amalgamSLR': {'color': brown, 'legend': 'Amalgam', 'marker': 'p'},
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
#     'codacoreB0.0SE': purple,
# }


res = pd.read_csv("./../out/quinn2020.csv")
res['ones'] = 1.0

print(res.groupby(['method']).sum())

means = res.groupby(['method', 'dataIdx'])
means = means.mean()
means = means.reset_index()

lassoMeans = means[means['method'] == 'rawLasso']
lassoMeans = lassoMeans.rename(columns={'accBL': "gain"})
# lassoMeans = lassoMeans.rename(columns={xVar: "gain"})
lassoMeans = lassoMeans.set_index('dataIdx')
lassoMeans = lassoMeans['gain']
# lassoMeans2 = means[means['method'] == 'rawXGB']
# lassoMeans2 = lassoMeans2.rename(columns={xVar: "gain"})
# lassoMeans2 = lassoMeans2.set_index('dataIdx')
# lassoMeans2 = lassoMeans2['gain']
means = means.join(lassoMeans, on='dataIdx', how='left')
means['gain'] = means[xVar] - means['gain']

# out = means[['method', 'dataIdx', 'inputDim', 'runTime', 'gain']]

means = means[means['method'].isin(methods)]

means['size'] = np.sqrt(means['inputDim']) * 5
means['size'] = means['inputDim'] / 10

colordf = pd.DataFrame(index=methods.keys(), data={'color': colors})
means = means.join(colordf, on='method', how='left')
markerdf = pd.DataFrame(index=methods.keys(), data={'marker': markers})
means = means.join(markerdf, on='method', how='left')

for method in methods:
    color = methods[method]['color']
    marker = methods[method]['marker']
    to_plot = means[means['method'] == method]
    plt.scatter(
        to_plot['runTime'],
        to_plot['gain'] * 100,
        s=to_plot['size'],
        c=color,
        marker=marker,
        alpha=0.7
    )

# plt.scatter(means['gain'] * 100, means['runTime'], s=means['size'], c=means['color'], alpha=0.7)
plt.xscale('log')
# plt.ylabel('$\Delta$ AUC w.r.t. Random Forest (%)')
plt.ylabel('Accuracy gain over baseline (%)')
plt.xlabel('Runtime (s)')
plt.axhline(linestyle='--', color='gray', alpha=0.5)

custom_legend = [Line2D([0], [0], lw=0, marker='o', color=c) for c in colors]
custom_legend = [Line2D([0], [0], lw=0, marker=m, color=c) for m, c in zip(markers, colors)]
# custom_lines = [Line2D([0], [0], lw=0, marker='o', color=orange),
#                 Line2D([0], [0], lw=3, color=pink),
#                 Line2D([0], [0], lw=3, color=blue),
#                 Line2D([0], [0], lw=3, color=purple),
#                 Line2D([0], [0], lw=3, color='gray'),
#                 Line2D([0], [0], lw=3, color='gray', linestyle='dotted')]
legend1 = plt.legend(custom_legend, legend_names, loc='lower right', handletextpad=0.1, prop={"size":12})
custom_legend = []
legend2 = plt.legend([Line2D([0], [0], linestyle='--', color='gray')], ['Random Forest'], loc='upper center')
custom_legend = [
    Line2D([0], [0], lw=0, marker='p', markersize=3.5, color='gray'),
    # Line2D([0], [0], lw=0, marker='o', markersize=5.5, color='gray'),
    Line2D([0], [0], lw=0, marker='p', markersize=10, color='gray'),
]
plt.legend(custom_legend, ['100 inputs', '1,000 inputs'], loc='lower left', handletextpad=0.1, prop={"size":12})
plt.gca().add_artist(legend1)
# plt.gca().add_artist(legend2)
# plt.legend()
plt.savefig("../manuscript/figures/runtimes.pdf")
plt.savefig("../out/figures/runtimes.pdf")
plt.show()
