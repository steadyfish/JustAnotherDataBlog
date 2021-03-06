# function to check and download (a list of) packages 
#e.g. checkAndDownload(c("plyr","sqldf"))
checkAndDownload<-function(packageNames) {
  for(packageName in packageNames) {
    if(!isInstalled(packageName)) {
      install.packages(packageName)
    } 
    library(packageName,character.only=TRUE,quietly=TRUE,verbose=FALSE)
  }
}

# function to check whether a particular package is already installed
# e.g. isInstalled("plyr")
isInstalled <- function(mypkg){
  is.element(mypkg, installed.packages()[,1])
}

#function to trip leading and trailing spaces
trim <- function (x) gsub("^\\s+|\\s+$", "", x)