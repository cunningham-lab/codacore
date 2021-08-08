# Adapted from Susin et al 2020
# https://github.com/malucalle/Microbiome-Variable-Selection/blob/master/simLogContrastCrohn.R

############################################################################
#   SIMULATION BASED ON CROHN MICROBIOME DATA (with log-contrast)
#
#  You have to choose the name of the scenario parameter file 
#  (default:  namefsimul = 'ParamCrohnSc1')
#  and the name of the output folder for the simulation results
#  (default: ItrLogContrast+namefsimul)
# 
############################################################################

#load DATA
# # Crohn's disease dataset
source("./R/loadData.R")
myData = loadQuinn2020(1) # Crohn data
D = myData$x

p<-ncol(D)  

start = Sys.time()

resCodacore = data.frame()
resSelbal = data.frame()
resCodalasso = data.frame()

ntrues = c(3, 5, 10)
nfalses = c(10, 20, 30, 40)

for (ntrue in ntrues) {
  for (nfalse in nfalses){
    
    # We put parameters here directly to simplify things instead of loading via csv
    niter = 10
    numObs = 975
    if (ntrue == 3) {
      coeffTrueModel = c(1., -.5, -.5) #taken from the original authors
    } else if (ntrue == 5) {
      coeffTrueModel = c(3, 3, -2, -2, -2) #taken from the original authors
    } else if (ntrue == 10) {
      coeffTrueModel = c(5, 5, 5, 5, 5, -5, -5, -5, -5, -5) #taken from the original authors
      if (nfalse == 40) {
        nfalse = 38 # to avoid having more columns than are available
      }
    }

    set.seed(12345)
    
    for(k in (1:niter)){ 
      # DATA simulation
      # At each iteration we generate a new dataset with ntrue positive and nfalse negatives:
      Pos<-sample(1:ncol(D),ntrue)
      Neg<-setdiff(1:ncol(D),Pos)
      Neg<-Neg[sample(1:length(Neg), nfalse)]
      
      # Selection of a submatrix of D
      X<-D[sample((1:nrow(D)),numObs),c(Pos,Neg)]   # we may reduce the number of individuals
      
      # Matrix of proportions
      X<-X/rowSums(X)
      
      # CLR transformation Z=log(X)
      z1<-log(X)
      clrz<- apply(z1,2,function (x) x-rowMeans(z1))
      
      # BETA simulations
      beta_i<-coeffTrueModel;  # coefficients of the true model 
      score1z<-as.matrix(log(X)[,(1:ntrue)])%*%(beta_i)   # linear predictor Z*beta
      
      # Y simulation
      prob1z<-1/(1+exp(-(score1z-mean(score1z))))  #logistic model
      #prob1z<-prob1z-mean(prob1z)+0.5
      y<-rep(0,nrow(z1))
      y<-as.numeric(runif(nrow(z1))<prob1z);
      
      if (T) {
        model = codacore(X, y, verbose=T, slow=T) # low p datasets here
        numFound = c()
        denFound = c()
        for (baseLearner in model$ensemble) {
          numFound = c(numFound, which(baseLearner$hard$numerator))
          denFound = c(denFound, which(baseLearner$hard$denominator))
        }
        numFound = unique(numFound)
        denFound = unique(denFound)
        found = c(numFound, denFound)
        
        numCorrect = sum(found %in% 1:ntrue)
        numIncorrect = sum(! found %in% 1:ntrue)

        tpr = (numCorrect) / (ntrue)
        fpr = (numIncorrect) / (ncol(X) - ntrue)
        
        res = data.frame(
          nfalse=nfalse,
          ntrue=ntrue,
          tpr = tpr,
          fpr = fpr
        )
        
        resCodacore = rbind(resCodacore, res)
      }
      
      
      if (T) {
        
        model = selbal::selbal.cv(x=X, y=y, maxV=20) # we keep maxV at default (otherwise much slower convergence)
        
        bal = model$global.balance
        numFound = bal$Taxa[bal$Group == 'NUM']
        denFound = bal$Taxa[bal$Group == 'DEN']
        found = c(numFound, denFound)

        numCorrect = sum(found %in% colnames(X)[1:ntrue])
        numIncorrect = sum(! found %in% colnames(X)[1:ntrue])

        tpr = (numCorrect) / (ntrue)
        fpr = (numIncorrect) / (ncol(X) - ntrue)
        
        res = data.frame(
          nfalse=nfalse,
          ntrue=ntrue,
          tpr = tpr,
          fpr = fpr
        )
  
        resSelbal = rbind(resSelbal, res)
      }
      
      if (T) {
        source('./R/codalasso.R')
        
        model = codalasso(X, y)
        
        found = which(model$cll$betas[-1] != 0)

        numCorrect = sum(found %in% 1:ntrue)
        numIncorrect = sum(! found %in% 1:ntrue)

        tpr = (numCorrect) / (ntrue)
        fpr = (numIncorrect) / (ncol(X) - ntrue)
        
        res = data.frame(
          nfalse=nfalse,
          ntrue=ntrue,
          tpr = tpr,
          fpr = fpr
        )
        
        resCodalasso = rbind(resCodalasso, res)
      }
    } 
  }
}

end = Sys.time()

print(end - start)

write.csv(resCodacore, file="./out/resCodacore.csv")
write.csv(resSelbal, file="./out/resSelbal.csv")
write.csv(resCodalasso, file="./out/resCodalasso.csv")

print("codacore mean and sd")
print(aggregate(resCodacore, by=list(nfalse=resCodacore$nfalse, ntrue=resCodacore$ntrue), FUN=mean))
print(aggregate(resCodacore, by=list(nfalse=resCodacore$nfalse, ntrue=resCodacore$ntrue), FUN=sd))

print("selbal mean and sd")
print(aggregate(resSelbal, by=list(nfalse=resSelbal$nfalse, ntrue=resSelbal$ntrue), FUN=mean))
print(aggregate(resSelbal, by=list(nfalse=resSelbal$nfalse, ntrue=resSelbal$ntrue), FUN=sd))

print("codalasso mean and sd")
print(aggregate(resCodalasso, by=list(nfalse=resCodalasso$nfalse, ntrue=resCodalasso$ntrue), FUN=mean))
print(aggregate(resCodalasso, by=list(nfalse=resCodalasso$nfalse, ntrue=resCodalasso$ntrue), FUN=sd))
