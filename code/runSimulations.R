
option_list = list(
  optparse::make_option("--method", type="character", default='codacoreB1.0'),
  optparse::make_option("--seed", type="character", default="0"),
  optparse::make_option("--gen", type="character", default="B"),
  optparse::make_option("--n", type="integer", default=200),
  optparse::make_option("--p", type="integer", default=10000),
  optparse::make_option("--k", type="integer", default=16)
)

opt_parser = optparse::OptionParser(option_list=option_list)
opt = optparse::parse_args(opt_parser)

method = opt$method
seed = opt$seed
gen = opt$gen # B or A for balance or amalgamation
n = opt$n # number of datapoints available
p = opt$p # dimensionality of the input
k = opt$k # number of active variables in numerator and denominator

simulateHTS = function(n, p, k, logratio = 'balance'){
  
  # Simulate independent variables
  alpha0 = rep(1.0, p) / log(p)
  alpha = gtools::rdirichlet(1, alpha0)
  alpha = sort(alpha, decreasing=T)
  X = matrix(0.0, n, p)
  numCounts = stats::rpois(n, 1000 * p)
  corruptRate = 1 / 1000
  for (i in 1:n) {
    classProb = gtools::rdirichlet(1, alpha)
    x = stats::rmultinom(1, numCounts[i], classProb)
    corrupt = sample(1:p, ceiling(corruptRate * p))
    x[corrupt] = x[corrupt] + stats::rpois(n, 1000)
    X[i,] = x
  }
  
  # Zero replace
  X = X + 1
  
  # For every 6 consecutive input variables,
  # we put the 2nd and 4th into the numerator,
  # and the 3rd and 6th into the denominator,
  # until we reach the desired number of variables.
  numVars = seq(2, p, by=2)
  denVars = seq(3, p, by=3)
  numVars = numVars[- which(numVars %in% denVars)]
  numVars = numVars[1:k]
  denVars = denVars[1:k]
  
  # Simulate response
  if (logratio == 'B') {
    eta = rowMeans(log(X[, numVars, drop=F])) - rowMeans(log(X[, denVars, drop=F]))
  } else if (logratio == 'A') {
    eta = log(rowSums(X[, numVars, drop=F])) - log(rowSums(X[, denVars, drop=F]))
  }

  outProb = 1 / (1 + exp(-(eta - mean(eta))))
  y = stats::rbinom(n, 1, outProb)

  return(list(x=data.frame(X), y=data.frame(y), numVars=numVars, denVars=denVars))
}

set.seed(seed)
sim = simulateHTS(n, p, k, logratio=gen)

if (substr(method, 1, 8) == 'codacore') {
  type = substr(method, 9, 9)
  lambda = as.numeric(substr(method, 10, 12))
  model = codacore::codacore(sim$x, sim$y, logRatioType=type, lambda=lambda)
  numFound = c()
  denFound = c()
  for (baseLearner in model$ensemble) {
    numFound = c(numFound, which(baseLearner$hard$numerator))
    denFound = c(denFound, which(baseLearner$hard$denominator))
  }
  numFound = unique(numFound)
  denFound = unique(denFound)
}

if (method == 'selbal') {
  
  model = selbal::selbal.cv(x=sim$x, y=sim$y$y,  n.fold=5, n.iter=10, logit.acc='AUC', maxV=20) # we keep maxV at default (otherwise much slower convergence)

  bal = model$global.balance
  numFound = bal$Taxa[bal$Group == 'NUM']
  denFound = bal$Taxa[bal$Group == 'DEN']
  numFound = as.numeric(sub("X", "", numFound))
  denFound = as.numeric(sub("X", "", denFound))

}


if (method == 'amalgam') {
  numAmal = 2 # 3 is the default value from amalgams, but an even number is needed for SLR
  
  amal = amalgam::amalgam(sim$x, z=sim$y$y, objective=amalgam::objective.maxRDA, 
                          asSLR=TRUE, n.amalgam=numAmal, monitor=F)
    
  numFound = which(as.logical(amal$weights[,1]))
  denFound = which(as.logical(amal$weights[,2]))
  
}

if (method == 'codalasso') {
  source('./R/codalasso.R')
  
  model = codalasso(sim$x, sim$y$y)

  numFound = which(model$cll$betas[-1] > 0)
  denFound = which(model$cll$betas[-1] < 0)
}

numCorrect = sum(numFound %in% sim$numVars)
denCorrect = sum(denFound %in% sim$denVars)
numIncorrect = sum(! numFound %in% sim$numVars)
denIncorrect = sum(! denFound %in% sim$denVars)

# Check whether we may have gotten things flipped around
if (numCorrect < sum(denFound %in% sim$numVars) & denCorrect < sum(numFound %in% sim$denVars)) {
  numCorrect = sum(numFound %in% sim$denVars)
  denCorrect = sum(denFound %in% sim$numVars)
  numIncorrect = sum(! numFound %in% sim$denVars)
  denIncorrect = sum(! denFound %in% sim$numVars)
}

tpr = (numCorrect + denCorrect) / (length(sim$numVars) + length(sim$denVars))
fpr = (numIncorrect + denIncorrect) / (p - length(sim$numVars) - length(sim$denVars))

res = data.frame(
  method = method,
  seed = seed,
  gen = gen,
  n = n,
  p = p,
  k = k,
  tpr = tpr,
  fpr = fpr
)

outDir = './out/simulations/'
fileName = paste0('sim.method', method, 
                  '.seed', as.character(seed), 
                  '.gen', gen, 
                  '.n', as.character(n), 
                  '.p', as.character(p), 
                  '.k', as.character(k))
write.csv(res, paste0(outDir, fileName))
print(res)
