
#########################################################################
# This is the R script that runs our models on data and saves the results
#########################################################################

option_list = list(
  optparse::make_option("--method", type="character", default='rawXGB'),
  optparse::make_option("--seed", type="character", default="1"),
  optparse::make_option("--dataIdx", type="integer", default=1),
  optparse::make_option("--nSim", type="integer", default=NULL),
  optparse::make_option("--kSim", type="integer", default=NULL)
)

opt_parser = optparse::OptionParser(option_list=option_list)
opt = optparse::parse_args(opt_parser)

method = opt$method
seed = opt$seed
dataIdx = opt$dataIdx
nSim = opt$nSim
kSim = opt$kSim

source("./code/loadData.R")

runAndSave = function(x, y, method, seed, dataArg) {
  
  # Set seed
  set.seed(seed)

  
  # Convert y to numeric
  y[[1]] = as.numeric(as.factor(y[[1]])) - 1
  
  numObs = nrow(x)
  inputDim = ncol(x)
  
  trainIdx = 1:numObs
  caseIdx = sample(cut(1:sum(y), breaks=5, labels=F))
  controlIdx = sample(cut(1:sum(1 - y), breaks=5, labels=F))
  trainIdx[y == 1] = caseIdx
  trainIdx[y == 0] = controlIdx
  xTr = x[trainIdx != 1,]
  yTr = y[trainIdx != 1,]
  xTe = x[trainIdx == 1,]
  yTe = y[trainIdx == 1,]
  
  # # trainIdx = sample(n, ceiling(0.66 * n))
  # trainIdx = rep(FALSE, n)
  # trainIdx[sample(n, ceiling(0.66 * n))] = TRUE
  # xTr = x[trainIdx,]
  # yTr = y[trainIdx,]
  # xTe = x[!trainIdx,]
  # yTe = y[!trainIdx,]
  
  if (substr(method, 1, 9) == 'codacore') {
    source("code/codacore.R")
    # Load up TF (should not be timed!)
    keras::k_zeros(0)
    # keras::use_session_with_seed(0) # breaks depending on version
    
    type = substr(method, 10, 10)
    gamma = as.numeric(substr(method, 11, 13))

    # run method
    startTime = Sys.time()
    model = codacore(xTr, yTr, type=type, gamma=gamma)
    endTime = Sys.time()
    yHatTr = predict(model, xTr)
    yHatTe = predict(model, xTe)
    
    activeVars = length(activeInputs.codacore(model))
  }
  
  if (method %in% c('rawLasso', 'rawRidge', 'clrLasso', 'clrRidge')) {
    if (method %in% c('rawLasso', 'clrLasso')) alpha = 1
    if (method %in% c('rawRidge', 'clrRidge')) alpha = 0
    
    startTime = Sys.time()
    if (method %in% c('clrLasso', 'clrRidge')) {
      xTr = compositions::clr(xTr)
      xTe = compositions::clr(xTe)
    } else {
      xTr = as.matrix(xTr)
      xTe = as.matrix(xTe)
    }
    
    model = glmnet::cv.glmnet(xTr, yTr, family='binomial', alpha=alpha, intercept=T)
    endTime = Sys.time()
    
    yHatTr = as.numeric(predict(model, newx = xTr, s = "lambda.1se"))
    yHatTe = as.numeric(predict(model, newx = xTe, s = "lambda.1se"))
    
    activeVars = sum(coef(model, s='lambda.1se') != 0) - 1
  }
  
  if (method %in% c('rawRF', 'clrRF')) {
    
    startTime = Sys.time()
    if (method == 'clrRF') {
      xTr = compositions::clr(xTr)
      xTe = compositions::clr(xTe)
    } else {
      xTr = as.matrix(xTr / rowSums(xTr))
      xTe = as.matrix(xTe / rowSums(xTe))
    }
    
    model = randomForest::randomForest(xTr, as.factor(yTr))
    try({ # Tuning func fails spuriously under correlated inputs (known issue)
      model = randomForest::tuneRF(xTr, as.factor(yTr), doBest=TRUE)
    })
    endTime = Sys.time()
    
    yHatTr = predict(model, newdata = xTr, type='prob')[, 2]
    yHatTe = predict(model, newdata = xTe, type='prob')[, 2]
    # Move predictions away from 0/1 extrema to avoid numerical issues
    yHatTr = (yHatTr + 1e-5) / (1 + 2e-5)
    yHatTe = (yHatTe + 1e-5) / (1 + 2e-5)
    yHatTr = log(yHatTr / (1 - yHatTr))
    yHatTe = log(yHatTe / (1 - yHatTe))
    
    activeVars = inputDim
  }
  
  if (method %in% c('rawXGB', 'clrXGB')) {
    
    startTime = Sys.time()
    if (method == 'clrXGB') {
      xTr = compositions::clr(xTr)
      xTe = compositions::clr(xTe)
    } else {
      xTr = as.matrix(xTr / rowSums(xTr))
      xTe = as.matrix(xTe / rowSums(xTe))
    }
    
    params=list(objective='binary:logistic', eval_metric='error')
    nrounds = 100
    model = xgboost::xgb.cv(xTr, yTr, nrounds=nrounds, nfold=5, params=params, verbose=F)
    nrounds = which.min(model$evaluation_log$test_error_mean)
    model = xgboost::xgboost(xTr, yTr, nrounds=nrounds, params=params)
    endTime = Sys.time()
    
    yHatTr = predict(model, newdata = xTr)
    yHatTe = predict(model, newdata = xTe)
    # Move predictions away from 0/1 extrema to avoid numerical issues
    yHatTr = (yHatTr + 1e-5) / (1 + 2e-5)
    yHatTe = (yHatTe + 1e-5) / (1 + 2e-5)
    yHatTr = log(yHatTr / (1 - yHatTr))
    yHatTe = log(yHatTe / (1 - yHatTe))
    
    activeVars = inputDim
  }
  
  if (method == 'PRA') {
    startTime = Sys.time()
    PRA = propr::pra(xTr, ndim=10)
    xTr = log(xTr[PRA$best$Partner]) - log(xTr[PRA$best$Pair])
    xTe = log(xTe[PRA$best$Partner]) - log(xTe[PRA$best$Pair])
    xTr = as.matrix(xTr)
    xTe = as.matrix(xTe)
    
    model = glmnet::cv.glmnet(xTr, yTr, family='binomial', alpha=1, intercept=T)
    endTime = Sys.time()
    
    yHatTr = as.numeric(predict(model, newx = xTr, s = "lambda.1se"))
    yHatTe = as.numeric(predict(model, newx = xTe, s = "lambda.1se"))
    
    activeVars = sum(coef(model, s='lambda.1se') != 0) - 1
    activeVars = 2 * activeVars # 2 covariates to a pairwise logratio

    endTime = Sys.time()
  }
  
  if (method == 'codalasso') {
    source('./code/codalasso.R')
    
    startTime = Sys.time()
    # xTr = as.matrix(xTr)
    # xTe = as.matrix(xTe)
    
    model = codalasso(xTr, yTr)
    endTime = Sys.time()
    
    yHatTr = predict(model, xTr)
    yHatTe = predict(model, xTe)
    
    activeVars = sum(model$cll$betas != 0)
    endTime = Sys.time()
  }
  
  if (method %in% c('amalgamCLR', 'amalgamSLR')) {
    numAmal = 6 # 3 is the default value from amalgams, but an even number is needed for SLR
    
    startTime = Sys.time()
    if (method == 'amalgamCLR') {
      amal = amalgam::amalgam(xTr, z=yTr, objective=amalgam::objective.maxRDA, 
                              n.amalgam=numAmal, monitor=F)
      
      xGlmTr = compositions::clr(as.matrix(xTr) %*% amal$weights)
      xGlmTe = compositions::clr(as.matrix(xTe) %*% amal$weights)
      
      # Remove the last coordinate to avoid linear dependence
      xGlmTr = xGlmTr[, 1:(numAmal - 1)]
      xGlmTe = xGlmTe[, 1:(numAmal - 1)]
    } 
    
    if (method == 'amalgamSLR') {
      amal = amalgam::amalgam(xTr, z=yTr, objective=amalgam::objective.maxRDA, 
                              asSLR=TRUE, n.amalgam=numAmal, monitor=F)
      
      amalTr = as.matrix(xTr) %*% amal$weights
      amalTe = as.matrix(xTe) %*% amal$weights
      
      xGlmTr = matrix(nrow = nrow(xTr), ncol = numAmal / 2)
      xGlmTe = matrix(nrow = nrow(xTe), ncol = numAmal / 2)
      for (i in 1:(numAmal/2)) {
        xGlmTr[, i] = log(amalTr[, 2 * i - 1]) - log(amalTr[, 2 * i])
        xGlmTe[, i] = log(amalTe[, 2 * i - 1]) - log(amalTe[, 2 * i])
      }
      
    }
    
    tempDF = cbind(data.frame(y=yTr), data.frame(xGlmTr))
    
    # Note we use glm not glmnet since this corresponds to the
    # objective of the genetic algo
    model = glm(y~., dat=tempDF, family='binomial')
    endTime = Sys.time()
    
    yHatTr = as.numeric(predict(model, newdata = data.frame(xGlmTr)))
    yHatTe = as.numeric(predict(model, newdata = data.frame(xGlmTe)))
    
    activeVars = sum(amal$weights)
  }
  
  if (method == 'selbal') {
    
    
    startTime = Sys.time()
    model = selbal::selbal.cv(x=xTr, y=yTr, n.fold=5, n.iter=10, logit.acc='AUC')
    endTime = Sys.time()
    
    bal = model$global.balance
    pveBal = bal$Taxa[bal$Group == 'NUM']
    nveBal = bal$Taxa[bal$Group == 'DEN']
    
    # Training set
    V1 = rowMeans(log(xTr[pveBal])) - rowMeans(log(xTr[nveBal]))
    yHatTr = as.numeric(predict(model$glm, newdata = data.frame(V1)))
    
    # Test set
    V1 = rowMeans(log(xTe[pveBal])) - rowMeans(log(xTe[nveBal]))
    yHatTe = as.numeric(predict(model$glm, newdata = data.frame(V1)))
    
    activeVars = nrow(model$global.balance)
  }
  
  
  if (substr(method, 1, 8) == 'deepcoda') {
    source("code/deepcoda.R")
    # Load up TF (should not be timed!)
    keras::k_zeros(0)
    # keras::use_session_with_seed(0) # breaks depending on version
    
    if (method == 'deepcoda') {
      selfExplanation = FALSE
    } else if (method == 'deepcodaSE') {
      selfExplanation = TRUE
    }
    
    # run method
    startTime = Sys.time()
    model = deepcoda(xTr, yTr, selfExplanation)
    endTime = Sys.time()
    yHatTr = predict(model, xTr)
    yHatTe = predict(model, xTe)
    
    activeVars = numActiveVars.deepcoda(model)
  }
  
  if (substr(method, 1, 13) == 'logratiolasso') {
    
    zTr = log(xTr)
    mu = apply(zTr, 2, mean)
    sigma = apply(zTr, 2, sd)
    zTr = sweep(sweep(log(xTr), 2L, mu), 2, sigma, "/")
    zTe = sweep(sweep(log(xTe), 2L, mu), 2, sigma, "/")
    zTr = as.matrix(zTr)
    zTe = as.matrix(zTe)

    # run method
    startTime = Sys.time()
    model = logratiolasso::cv_two_stage(zTr, yTr, family="binomial")
    endTime = Sys.time()
    yHatTr = zTr %*% model$beta_min
    yHatTe = zTe %*% model$beta_min
    activeVars = sum(model$beta_min != 0)
  }
  
  # Compute metrics and store
  accBL = max(mean(yTr), 1 - mean(yTr)) # baseline accuracy
  
  accTr = mean(yTr == (yHatTr > 0))
  sensTr = sum((yHatTr > 0) & (yTr == 1)) / sum(yTr == 1) # aka recall / true positive rate
  specTr = sum((yHatTr < 0) & (yTr == 0)) / sum(yTr == 0) # aka true negative rate
  precTr = sum((yHatTr > 0) & (yTr == 1)) / sum(yHatTr > 0) # aka positive predictive value
  f1Tr = 2 / (1/sensTr + 1/precTr) # f1 is harmonic mean of precision & recall
  aucTr = pROC::auc(pROC::roc(yTr, yHatTr, quiet=T))
  
  accTe = mean(yTe == (yHatTe > 0))
  sensTe = sum((yHatTe > 0) & (yTe == 1)) / sum(yTe == 1) # aka recall / true positive rate
  specTe = sum((yHatTe < 0) & (yTe == 0)) / sum(yTe == 0) # aka true negative rate
  precTe = sum((yHatTe > 0) & (yTe == 1)) / sum(yHatTe > 0) # aka positive predictive value
  f1Te = 2 / (1/sensTe + 1/precTe) # f1 is harmonic mean of precision & recall
  aucTe = pROC::auc(pROC::roc(yTe, yHatTe, quiet=T))
  
  runTime = endTime - startTime
  units(runTime) = 'secs'
  runTime = as.numeric(runTime)
  
  res = data.frame(
    method = method,
    seed = seed,
    # data = dataSetNames[dataIdx],
    inputDim = inputDim,
    numObs = numObs,
    activeVars = activeVars,
    accBL = accBL,
    accTr = accTr,
    sensTr = sensTr,
    specTr = specTr,
    precTr = precTr,
    f1Tr = f1Tr,
    aucTr = aucTr,
    accTe = accTe,
    sensTe = sensTe,
    specTe = specTe,
    precTe = precTe,
    f1Te = f1Te,
    aucTe = aucTe,
    runTime = runTime
  )
  res$dataIdx = dataIdx # might be NULL so we add this at the end
  
  return(res)
}



# We have an 'all' option for the quick methods, 
# which runs all seeds on a single machine.
# The slow methods take up one core per run.
if (seed == 'all') {
  seeds = 1:20
} else {
  seeds = c(as.integer(seed))
}

baseFileName = paste0('runAndSave.method', method)
if (dataIdx %in% 1:25) {
  baseFileName = paste0(baseFileName, '.dataIdx', as.character(dataIdx)) 
  myData = loadQuinn2020(dataIdx)
  outDir = './out/quinn2020/'
} else if (dataIdx == 26) {
  # Data from Myron Best et al 2015
  myData = loadBest2015()
  outDir = './out/best2015/'
} else if (dataIdx == 27) {
  myData = loadBest2015(source='refine.bio1')
  outDir = './out/best2015refine.bio1/'
} else if (dataIdx == 28) {
  myData = loadBest2015(source='refine.bio2')
  outDir = './out/best2015refine.bio2/'
} else if (is.null(dataIdx) & is.integer(nSim) & is.integer(kSim)) {
  baseFileName = paste0(baseFileName, 
                        'nSim', as.character(nSim), 
                        'kSim', as.character(kSim))
  set.seed(nSim * kSim)
  myData = simulateData(nSim, kSim)
  outDir = './out/sim/'
} else {
  stop("Data args incorrectly specified.")
}

for (seed in seeds) {
  df1 = runAndSave(myData$x, myData$y, method, seed, dataArg)
  if (substr(getwd(), 1, 7) == '/Users/') {
    # Just print results when running locally
    print(df1)
  } else {
    # Save results when running in parallel on the cluster
    fileName = paste0(baseFileName, '.seed', as.character(seed))
    write.csv(df1, paste0(outDir, fileName))
  }
}



