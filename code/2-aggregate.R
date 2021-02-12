
numDatasets = 25
numSeeds = 20

inDir = './out/quinn2020/'
fileNames = list.files(inDir)

res = list()

for (file in fileNames) {
  df = read.csv(paste0(inDir, file))
  res = c(res, list(df))
}

rawRes = do.call(rbind, res)
write.csv(rawRes, './out/quinn2020.csv')

rawRes$ones = 1
by = list(
  method=rawRes$method,
  dataIdx=rawRes$dataIdx
)
out = aggregate(rawRes[c('ones')], by=by, FUN=sum)

print("Uncompleted runs by dataset:")
print(out[out$ones != numSeeds,])

by = list(
  method=rawRes$method
)
out = aggregate(rawRes[c('ones')], by=by, FUN=sum)

print("Uncompleted runs:")
print(out[out$ones != numSeeds * numDatasets,])

print("Completed runs:")
print(out[out$ones == numSeeds * numDatasets,])


