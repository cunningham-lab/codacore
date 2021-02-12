
library(plyr)
library(tidyr)

rawRes = read.csv('./out/quinn2020.csv')

methods = c(
  # "rawLasso", 
  "codacoreB1.0SE", 
  "codacoreA1.0SE",
  "selbal", 
  "PRA", 
  "codalasso",
  "amalgamSLR",
  "deepcodaSE",
  "rawRF"
)

vars = c('inputDim', 'accTe', 'aucTe', 'activeVarsP', 'runTime')

rawRes$activeVars[rawRes$method=='clrLasso'] = rawRes$inputDim[rawRes$method=='clrLasso']
rawRes$activeVarsP = rawRes$activeVars / rawRes$inputDim

show = c('aucTe', 'accTe', 'activeVarsP', 'runTime')

cat("First we generate supplementary tables broken down by dataset\n\n\n")

for (var in show) {
  
  cat('\n\n\n\n\n\n\n\n\n\n', var)
  
  means = aggregate(rawRes[vars], by=list(method=rawRes$method, dataIdx=rawRes$dataIdx), FUN=mean)
  stds = aggregate(rawRes[vars], by=list(method=rawRes$method, dataIdx=rawRes$dataIdx), FUN=sd)
  stds[vars] = stds[vars] / sqrt(5)
  
  means = spread(means[c('method', 'dataIdx', var)], method, var)
  stds = spread(stds[c('method', 'dataIdx', var)], method, var)
  
  means = rbind(means, colMeans(means))
  stds = rbind(stds, colMeans(stds))
  
  if (var != 'runTime') {
    means = round(100 * means, 2)
    stds = round(100 * stds, 2)
  }

  # Generate latex table:
  for (dataIdx in 1:26) {
    cat('\n')
    if (dataIdx <= 25) {
      cat(dataIdx)
    } else {
      cat('\\midrule \n Mean')
    }
    for (method in methods) {
      m = means[dataIdx, method]
      isMax = (var %in% c('aucTe', 'accTe'))
      isMax = F
      for (method2 in methods) {
        if (m < means[dataIdx, method2]) {isMax = FALSE}
      }
      if (var == 'runTime') {
        m = round(m)
      } else if (var == 'activeVarsP') {
        m = sprintf(m, fmt='%#.1f')
      } else {
        m = sprintf(m, fmt='%#.1f')
        # m = round(m)
      }

      if (isMax) {
        cat(' & \\textbf{', m, '}')
      } else{
        cat(' &', m)
      }
      s = stds[dataIdx, method]
      if (var != 'runTime') {
        # if (method == 'rawRF') {next}
        s = sprintf(s, fmt='%#.1f')
        cat('$\\pm$', s, '', sep='')
      # } else if (var != 'runTime') {
      #   cat(' $\\pm$', round(s), '', sep='')
      }
    }
    cat(' \\\\')
  }
}


methods = list(
  "codacoreB1.0SE"="\\textbf{CoDaCoRe - Balances (ours)}",
  "codacoreA1.0SE"="CoDaCoRe - Amalgamations (ours)",
  "selbal"="selbal \\cite{rivera2018balances}", 
  "PRA"="Pairwise Log-ratios  \\cite{greenacre2019variable}",
  # "codacoreB0.5SE"="CoDaCoRe-Balances (ours)",
  # "codacoreA0.5SE"="CoDaCoRe-Amalgamations (ours)",
  # "codacoreB1.0SE"="CoDaCoRe (Balance, 1-SE)",
  # "codacoreB0.0SE"="CoDaCoRe (Balance, 0-SE)",
  # "codacoreA1.0SE"="CoDaCoRe (Amalgamation, 1-SE)",
  # "codacoreA0.0SE"="CoDaCoRe (Amalgamation, 0-SE)",
  "rawLasso"="Lasso", 
  "codalasso"="Coda-lasso \\cite{lu2019generalized}",
  "amalgamSLR"="amalgam \\cite{quinn2020amalgams}",
  # "deepcoda"="Coda-lasso \\cite{susin2020variable}",
  "deepcodaSE"="DeepCoDA \\cite{quinn2020deepcoda}",
  "clrLasso"="CLR-lasso \\cite{susin2020variable}",
  # "clrRF"="Random Forest (clr)",
  "rawRF"="Random Forest",
  "rawXGB"="XGBoost"
  # "clrXGB"="XGBoost (clr)",
)

vars = c('inputDim', 'accTe', 'aucTe', 'activeVarsP', 'sensTe', 'specTe', 'runTime', 'f1Te')
means = aggregate(rawRes[vars], by=list(method=rawRes$method, dataIdx=rawRes$dataIdx), FUN=mean)
stds = aggregate(rawRes[vars], by=list(method=rawRes$method, dataIdx=rawRes$dataIdx), FUN=sd)
# Adjust for the fact that each test fold is 1/5 of the data
stds[vars] = stds[vars] / sqrt(5)

cat("Then we generate main summary table for the main manuscript\n\n\n")

for (i in 1:length(methods)) {
  # if (i == which(names(methods) == 'deepcoda')) {cat('\n \\midrule %\\midrule')}
  cat('\n')
  # if (substr(names(methods)[i], 1, 10) == 'codacoreB') {
  #   cat('\\textbf{', methods[[i]], '}')
  # } else {
    cat(methods[[i]])
  # }
  for (j in c('runTime', 'activeVarsP', 'accTe', 'aucTe')) {
    m = mean(means[means$method == names(methods)[i], j])
    s = mean(stds[stds$method == names(methods)[i], j])
    # m = sprintf(m, fmt='%#.2f')
    
    if (j == 'runTime') {
      m = round(m, 1)
      s = round(s, 1)
    } else {
      m = round(100 * m, 1)
      s = round(100 * s, 1)
    }
    
    m = format(m, nsmall=1, big.mark=',')
    # s = sprintf(100 * s, fmt='%#.1f')
    s = format(s, nsmall=1, big.mark=',')
    
    # if (j == 'runTime' ) {
    #   m = sprintf(m, fmt='%#.1f')
    #   s = sprintf(s, fmt='%#.1f')
    # } else if (j == 'activeVarsP') {
    #   m = sprintf(100 * m, fmt='%#.1f')
    #   s = sprintf(100 * s, fmt='%#.1f')
    # } else {
    #   m = sprintf(100 * m, fmt='%#.1f')
    #   s = sprintf(100 * s, fmt='%#.1f')
    #   # m = as.character(round(m * 100))
    #   # s = as.character(round(s * 100))
    # }
    
    if (names(methods)[i] %in% c('rawRF', 'rawXGB') & j == 'activeVarsP') {
      cat('&  &\\ $\\cdot$')
      next
    }
    
    # s = sprintf(s, fmt='%#.2f')
    cat(' & ')
    bold = names(methods)[i] == 'codacoreB1.0SE'
    # bold = names(methods)[i] == 'codacoreB0.0SE' & j %in% c('aucTe', 'accTe')
    # bold = bold | (names(methods)[i] == 'codacoreB1.0SE' & j == 'activeVarsP')
    if (bold) {
      cat('\\textbf{', m, '}', sep='')
    } else{
      cat(m)
    }
    # if (j != 'runTime') {
    if (bold) {
      # cat('', m, '}', sep='')
      cat('&\\textbf{$\\pm$', s, '}', sep='')
    } else{
      cat('&$\\pm$', s, '', sep='')
    }
    # cat('&$\\pm$', s, '', sep='')
    # }
    # if (bold) {cat('}')}
  }
  cat(' \\\\')
}


