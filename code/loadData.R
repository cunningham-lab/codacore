

# Data loading funcs

# We have a data-loading function that reads our data into the workspace,
# we have a data-simulation function for our simulation studies,

loadQuinn2020 = function(dataIdx) {
  inDir = './in/quinn2020/'
  files <- list.files(inDir)
  dataSetNames <- unique(gsub("(-x\\.csv)|(-y\\.csv)", "", files))
  
  x <- read.csv(paste0(inDir, dataSetNames[dataIdx], "-x.csv"), row.names = 1)
  y <- read.csv(paste0(inDir, dataSetNames[dataIdx], "-y.csv"), row.names = 1)
  
  # If y has more than one column we just keep the response variable
  if (ncol(y) >= 2) {y = y['Var']}
  
  return(list(x=x, y=y))
}

# For the larger mRNA cancer data from Best et al 2015
loadBest2015 = function(type='pan-cancer', source="counts") {
  inDir = './in/best2015/'
  
  if (source == "counts") {
    name = 'recount2-SRP057500-7class'
    
    x = read.csv(paste0(inDir, name, "-x.csv"), row.names = 1)
    y = read.csv(paste0(inDir, name, "-y.csv"), row.names = 1)
    
    x = t(x)
    x = x + 1
    x = x / rowSums(x)
  
    if (type == 'pan-cancer') {
      y[,] = 1 - (y[,] == 'cancer type: HC')
    } else if (type == 'multiclass') {
      y[,] = as.factor(y[,])
    } else {stop("Type incorrectly specified.")}
  } else if (substr(source, 1, 10) == "refine.bio") {
    x = read.table(paste0(inDir, source, '/SRP057500.tsv'), sep='\t', row.names=1, header=T)
    y = read.table(paste0(inDir, source, '/metadata_SRP057500.tsv'), sep='\t', header=T)

    if (any(y[,1] != colnames(x))) {stop("Input data is misaligned.")}
    
    x = t(x)
    
    if (any(x < 0)) {
      x = x - min(x)
    }
    
    # Zero replacement:
    if (any(x == 0)) {
      minVal = min(x[x > 0])
      x = x + minVal / 10
    }
    

    y = y['refinebio_title']
    y[,] = lapply(y, function(s) {substr(s, 1, 18)})
    if (type == 'pan-cancer') {
      y[,] = 1 - (y[,] == 'Blood_Platelets_HC')
    } else if (type == 'multiclass') {
      y[,] = as.factor(y[,])
    } else {stop("Type incorrectly specified.")}
    
  } else {
    stop("Source incorrectly specified.")
  }

  return(list(x=x, y=y))
}

simulateData = function(N, K){
  # Generate X
  alpha0 = rep(1.0, K) / 10.0
  alpha = gtools::rdirichlet(1, alpha0)
  alpha = sort(alpha, decreasing=T) * 10.0
  X = matrix(0.0, N, K)
  for (i in 1:N) {
    p = gtools::rdirichlet(1, alpha)
    x = rmultinom(1, K * 10, p) + 0.001 #TODO: Remove the epsilon once cmultRepl fixed!
    X[i,] = x / sum(x)
  }
  
  # Generate y
  eps = 1e-6
  eta = log(eps + rowSums(X[, c(1,2,6,7,15)])) - log(eps + rowSums(X[, c(3,8,16,17)]))
  eta = eta + 0.2 * (log(eps + rowSums(X[, c(10,11)])) - log(eps + rowSums(X[, c(12,19)])))
  successes = (eta > mean(eta)) * 1.0
  
  # Or the noisy version
  p = 1 / (1 + exp(-(eta - mean(eta)))) * 1.0
  y = rbinom(N, 1, p)
  
  return(list(x=data.frame(X), y=data.frame(y)))
}


