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


myfunc <- function(lst_elmnt){
  as.data.frame(t(unlist(lst_elmnt)), stringsAsFactors = FALSE)
}
currentItr = 0
returnCount = 1
while(returnCount>0){
  JSONList = getJSONDoc(link="http://data.gov.in/api/datastore/resource.json?",
                         res_id="5255d770-6cc9-44bc-befe-e65eff5b51e2",
                         api_key="4a6b520b59fab36f4c78f8bac1a0afcf",
                         offset=currentItr,
                         no_elements=100)
  DataStage1 = ldply(getData(JSONList),myfunc)
  print(currentItr)
  print(is(DataStage1$id))
  returnCount = getCount(JSONList)
  if(currentItr == 0) {
    hotelData = DataStage1
    hotelFieldType = ldply(getFieldType(JSONList),myfunc)
  }
  else if(returnCount > 0) hotelData = rbind(hotelData, DataStage1)
  print(currentItr)
  print(is(hotelData$id))
  currentItr = currentItr + 1  
}

save(hotelData, file=file.path(w_dir,"Data/hotelData.RData"))
save(hotelFieldType, file=file.path(w_dir,"Data/hotelFieldType.RData"))

#to do or next commit:
#2 try is there s an easy, better way of doing these conversion from list to a data.table
#3 resolve the issue of all the fields being treated as text
#It would have been a lot easier if they had APIs in place 
#to download the data, but it's not the case. API is available
#just for one of the datasets.
