####Download the data from Government of India open data portal#####
w_dir = getwd()
source(file=file.path(w_dir,"Code/Core.R"))
checkAndDownload(c("XML","RCurl","RJSONIO","plyr"))

### Alternative - 1: Using APIs ###
#JSON#
getJSONDoc <- function(link, res_id, api_key, offset, no_elements){
  jsonURL = paste(link,
                  "resource_id=",res_id, 
                  "&api-key=",api_key,
                  "&offset=",offset,
                  "&limit=",no_elements,
                  sep="")
  print(jsonURL)
  doc = getURL(jsonURL)
  fromJSON(doc)
}
getFieldNames <- function(t){
#t: list
  names(t[[4]])
}
getCount <- function(t){
  #t: list
  t[[3]]
}
getFieldType<-function(t){
  t[[4]]
}  
getData <- function(t){
  t[[5]]
}
toDataFrame <- function(lst_elmnt){
  as.data.frame(t(unlist(lst_elmnt)), stringsAsFactors = FALSE)
}
acquire_x_alldata <- function(x,res_id,api_key){
  currentItr = 0
  returnCount = 1
  while(returnCount>0){
    JSONList = getJSONDoc(link="http://data.gov.in/api/datastore/resource.json?",
                           res_id=res_id,
                           api_key=api_key,
                           offset=currentItr,
                           no_elements=100)
    DataStage1 = ldply(getData(JSONList),toDataFrame)
    print(currentItr)
    print(is(DataStage1$id))
    returnCount = getCount(JSONList)
    if(currentItr == 0) {
      returnData = DataStage1
      returnFieldType = ldply(getFieldType(JSONList),toDataFrame)
    }
    else if(returnCount > 0) returnData = rbind(returnData, DataStage1)
    print(currentItr)
    print(is(returnData$id))
    currentItr = currentItr + 1  
  }
  list(returnData,returnFieldType)
}

#to do for future commits:
#try ig there is an easy, better way of doing these conversion from list to a data.table
#resolve the issue of all the fields being treated as text
#It would have been a lot easier if they had APIs in place 
#to download the data, but it's not the case. API is available
#just for three of the datasets.
