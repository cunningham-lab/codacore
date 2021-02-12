
source("code/codacore.R")

# Set seed to make our plots reproducible
set.seed(1)
keras::use_session_with_seed(1)

library(selbal)
data("Crohn")
dim(Crohn)

x <- Crohn[,-ncol(Crohn)]
y <- Crohn[,ncol(Crohn)]

# Run master AmalgamBoost...
res <- codacore(x, y, type = 'A', maxBaseLearners = 1, gamma = 1)
ratios <- getLogRatios(res)
boxplot(ratios[,1] ~ y)

# Bootstrap AmalgamBoost...
B <- 10
all_res <- lapply(1:B, function(b){
  # Stratified sampling
  index <- 1:nrow(x)
  yNumeric = as.numeric(y)-1
  caseIndex <- sample(cut(1:sum(yNumeric), breaks=5, labels=F))
  controlIndex <- sample(cut(1:sum(1 - yNumeric), breaks=5, labels=F))
  index[yNumeric == 1] = caseIndex
  index[yNumeric == 0] = controlIndex
  x.boot = x[index != 1,]
  y.boot = y[index != 1]
  # # Vanilla sampling
  # index <- sample(1:nrow(x), .67*nrow(x))
  # x.boot <- x[index,]
  # y.boot <- y[index]
  res <- codacore(x.boot, y.boot, type = 'A', maxBaseLearners = 1, gamma = 1)
})

# Summarize with table +1 for numerator, -1 for denominator
pos <- do.call("rbind", lapply(all_res, getNumeratorParts)) * 1
neg <- do.call("rbind", lapply(all_res, getDenominatorParts)) * -1
member <- pos+neg
colnames(member) <- colnames(x)

# Does inclusion associate with abundance?
png("analysis_thom/1-Crohn-ab-trend-mean.png", width = 4, height = 4, res = 600, units = "in")
plot(abs(colSums(member))/B*100, colMeans(res$x)*100,
     ylab = "Average Bacteria Presence in Samples (Percent)",
     xlab = "Inclusion in Amalgamated Ratio (Percent)",
     pch=16)
dev.off()
png("analysis_thom/1-Crohn-ab-trend-var.png", width = 4, height = 4, res = 600, units = "in")
plot(abs(colSums(member))/B*100, apply(x, 2, var),
     ylab = "Variance of Bacteria Across Samples",
     xlab = "Inclusion in Amalgamated Ratio (Percent)",
     pch=16)
dev.off()

# Save a heatmap of results
member <- member[,!colSums(member) == 0]
member <- member[,order(colSums(member))]
png("analysis_thom/1-Crohn-ab-heatmap.png", width = 6, height = 4, res = 600, units = "in")
heatmap(t(member), scale = "none", Colv = NA, Rowv = NA, labCol = "")
dev.off()
write.csv(t(member), './out/heatmapAmalgamation.csv')











# Set seed to make our plots reproducible
set.seed(1)
keras::use_session_with_seed(1)

library(selbal)
data("Crohn")
dim(Crohn)

x <- Crohn[,-ncol(Crohn)]+1
y <- Crohn[,ncol(Crohn)]

# Run master codacore
res <- codacore(x, y, type = 'B', maxBaseLearners = 1, gamma = 1)
res$X <- x
res$y <- y
#ratios <- getRatios(res)
#boxplot(ratios[,1] ~ y)

# Bootstrap AmalgamBoost...
B <- 10
all_res <- lapply(1:B, function(b){
  # Stratified sampling
  index <- 1:nrow(x)
  yNumeric = as.numeric(y)-1
  caseIndex <- sample(cut(1:sum(yNumeric), breaks=5, labels=F))
  controlIndex <- sample(cut(1:sum(1 - yNumeric), breaks=5, labels=F))
  index[yNumeric == 1] = caseIndex
  index[yNumeric == 0] = controlIndex
  x.boot = x[index != 1,]
  y.boot = y[index != 1]
  # # Vanilla sampling
  # index <- sample(1:nrow(x), .67*nrow(x))
  # x.boot <- x[index,]
  # y.boot <- y[index]
  res <- codacore(x.boot, y.boot, type = 'B', maxBaseLearners = 1, gamma = 1)
  res$X <- x.boot
  res$y <- y.boot
  res
  # print(sort(res$ensemble[[1]]$softMask)[1:5])
  # print(sort(-res$ensemble[[1]]$softMask)[1:5])
})

# Summarize with table +1 for numerator, -1 for denominator
pos <- do.call("rbind", lapply(all_res, getNumeratorParts)) * 1
neg <- do.call("rbind", lapply(all_res, getDenominatorParts)) * -1
member <- pos+neg
colnames(member) <- colnames(x)

# Does inclusion associate with abundance?
png("analysis_thom/2-Crohn-bb-trend-mean.png", width = 4, height = 4, res = 600, units = "in")
plot(abs(colSums(member))/B*100, colMeans(res$x)*100,
     ylab = "Average Bacteria Presence in Samples (Percent)",
     xlab = "Inclusion in Amalgamated Ratio (Percent)",
     pch=16)
dev.off()
png("analysis_thom/2-Crohn-bb-trend-var.png", width = 4, height = 4, res = 600, units = "in")
plot(abs(colSums(member))/B*100, apply(x, 2, var),
     ylab = "Variance of Bacteria Across Samples",
     xlab = "Inclusion in Amalgamated Ratio (Percent)",
     pch=16)
dev.off()

# Save a heatmap of results
member <- member[,!colSums(member) == 0]
member <- member[,order(colSums(member))]
png("analysis_thom/2-Crohn-bb-heatmap.png", width = 6, height = 4, res = 600, units = "in")
heatmap(t(member), scale = "none", Colv = NA, Rowv = NA, labCol = "")
dev.off()
write.csv(t(member), './out/heatmapBalance.csv')
