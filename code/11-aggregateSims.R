

inDir = './out/simulations/'
fileNames = list.files(inDir)

res = list()

for (file in fileNames) {
  df = read.csv(paste0(inDir, file))
  res = c(res, list(df))
}

rawRes = do.call(rbind, res)
write.csv(rawRes, './out/simulations.csv')

