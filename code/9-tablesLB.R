

numSeeds = 20

inDir = './out/best2015/'
fileNames = list.files(inDir)

res = list()

for (file in fileNames) {
  df = read.csv(paste0(inDir, file))
  res = c(res, list(df))
}

rawRes = do.call(rbind, res)
write.csv(rawRes, './out/best2015.csv')

rawRes$ones = 1
by = list(
  method=rawRes$method,
  dataIdx=rawRes$dataIdx
)
out = aggregate(rawRes[c('ones')], by=by, FUN=sum)

print("Uncompleted runs:")
print(out[out$ones != numSeeds,])




vars = c('inputDim', 'accTe', 'aucTe', 'activeVars', 'runTime')

rawRes$activeVars[rawRes$method=='clrLasso'] = rawRes$inputDim[rawRes$method=='clrLasso']


methods = list(
  "codacoreB1.0SE"="CoDaCoRe",
  # "codacoreA1.0SE"="CoDaCoRe-Amalgamations (ours)",
  "rawLasso"="Lasso", 
  "rawRF"="RF",
  "rawXGB"="XGBoost"
)

vars = c('inputDim', 'aucTe', 'accTe', 'activeVars', 'sensTe', 'specTe', 'runTime')
means = aggregate(rawRes[vars], by=list(method=rawRes$method, dataIdx=rawRes$dataIdx), FUN=mean)
stds = aggregate(rawRes[vars], by=list(method=rawRes$method, dataIdx=rawRes$dataIdx), FUN=sd)
# Adjust for the fact that each test fold is 1/5 of the data
stds[vars] = stds[vars] / sqrt(5)
for (i in 1:length(methods)) {
  cat('\n')
  cat(methods[[i]])
  for (j in c('runTime', 'activeVars', 'accTe', 'aucTe')) {
    m = mean(means[means$method == names(methods)[i], j])
    s = mean(stds[stds$method == names(methods)[i], j])
    # m = sprintf(m, fmt='%#.2f')
    # if (j == 'runTime' ) {
    #   m = sprintf(m, fmt='%#.1f')
    #   s = sprintf(s, fmt='%#.1f')
    if (j %in% c('runTime', 'activeVars')) {
      m = sprintf(m, fmt='%#.1f')
      s = sprintf(s, fmt='%#.1f')
    } else {
      m = sprintf(100 * m, fmt='%#.1f')
      s = sprintf(100 * s, fmt='%#.1f')
    }

    # s = sprintf(s, fmt='%#.2f')
    cat(' & ')
    bold = names(methods)[i] == 'codacoreB1.0SE'
    bold = F
    # bold = names(methods)[i] == 'codacoreB0.0SE' & j %in% c('aucTe', 'accTe')
    # bold = bold | (names(methods)[i] == 'codacoreB1.0SE' & j == 'activeVarsP')
    # if (bold) {
    #   cat('\\textbf{', m, sep='')
    # } else{
    #   cat(m)
    # }
    if (as.numeric(m) > 50000) {
      cat('$\\cdot$ \\ \\')
    } else {
      cat(m)
      cat('$\\pm$', s, '', sep='')
    }
    
  }
  cat(' \\\\')
}




