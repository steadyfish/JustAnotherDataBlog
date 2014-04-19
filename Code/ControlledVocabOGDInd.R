#OGD India portal has a link to their controlled vocabulary service website - vocab.nic.in
#Some of the controlled vocab seems useful, for e.g. list of countries, states sectors, subsectors etc.

#This script downloads these selected controlled vocabs in JSON format and stores as an .RData

w_dir = getwd()
source(file=file.path(w_dir,"Code/Core.R"))
checkAndDownload(c("RCurl","RJSONIO","plyr"))

resourceList = read.table(
  file=file.path(w_dir,"Data/goi_ogd_controlled_vocab_links.csv"),
  header=TRUE,
  sep=",",
  as.is=TRUE)

getJSONVoc <- function(jsonURL){
  print(jsonURL)
  doc = getURL(jsonURL)
  fromJSON(doc)
}

len = nrow(resourceList)
for(itr in 1:len) {
  datastage1 = getJSONVoc(resourceList[itr,2])
  datastage2 = t(unlist(datastage1, recursive = FALSE))
  data_df = ldply(datastage2, unlist)
  
  save(data_df, file=file.path(w_dir,paste0("Data/controlled_vocab",resourceList[itr,1],".RData")))
}

