
################################
# Careful! Input csvs have some mismatched rows (fixed manually in excel)
# Also, there are 5 repeated Healthy controls
####################3

dataName = 'recount2-SRP057500-7class'
yVar = 'V4'


xDir = paste0('./in/', dataName, '/data/')
xFiles = list.files(xDir)
yDir = paste0('./in/', dataName, '/annot/')
yFiles = list.files(yDir)
xDfs = list()
yDfs = list()
for (i in 1:length(xFiles)) {
  print(i)
  df = read.csv(paste0(xDir, xFiles[i]), row.names=1)
  xDfs = c(xDfs, list(df))
  df = read.csv(paste0(yDir, yFiles[i]), row.names=1)
  y = df[yVar]
  yDfs = c(yDfs, list(y))
}
# Check that the rownames all make sense
rn = rownames(xDfs[[1]])
for (df in xDfs) {if (any(rn != rownames(df))) {stop("something misaligned!")}}

x = do.call(cbind, xDfs)
y = do.call(rbind, yDfs)


write.csv(x, paste0('./in/best2015/', dataName, '-x.csv'))
write.csv(y, paste0('./in/best2015/', dataName, '-y.csv'))



