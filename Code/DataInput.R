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

currentItr = 0
JSONList1 = getJSONDoc(link="http://data.gov.in/api/datastore/resource.json?",
                      res_id="5255d770-6cc9-44bc-befe-e65eff5b51e2",
                      api_key="4a6b520b59fab36f4c78f8bac1a0afcf",
                      offset=currentItr,
                      no_elements=5)

currentItr = 1
JSONList2 = getJSONDoc(link="http://data.gov.in/api/datastore/resource.json?",
                       res_id="5255d770-6cc9-44bc-befe-e65eff5b51e2",
                       api_key="4a6b520b59fab36f4c78f8bac1a0afcf",
                       offset=currentItr,
                       no_elements=5)

currentItr = 0
JSONList3 = getJSONDoc(link="http://data.gov.in/api/datastore/resource.json?",
                       res_id="5255d770-6cc9-44bc-befe-e65eff5b51e2",
                       api_key="4a6b520b59fab36f4c78f8bac1a0afcf",
                       offset=currentItr,
                       no_elements=10)
hotelData1 = ldply(lapply(getData(JSONList1),t),data.frame, stringsAsFactors = FALSE)
hotelData2 = ldply(lapply(getData(JSONList2),t),data.frame, stringsAsFactors = FALSE)
hotelData3_bind = rbind(hotelData1, hotelData2)
hotelData3 = ldply(lapply(getData(JSONList3),t),data.frame, stringsAsFactors = FALSE)
#Example function calls
#getFieldNames(JSONList)
#getCount(JSONList)
#getFieldType(JSONList)

#Future extensions: get field type information, map to corresponding R fields


#list to dataframe
#3.return value is a data.frame, all the cells are text
hotelData = ldply(lapply(getData(JSONList),t),data.frame, stringsAsFactors = FALSE)
hotelFieldType = ldply(lapply(getFieldType(JSONList),t),data.frame, stringsAsFactors = FALSE)

#to do or next commit:
#recursive pings to get data, additional parameter for the json link
#1 use one of hotelData2, hotelData3 going forward
#2 try is there s an easy, better way of doing these conversion from list to a data.table
#3 resolve the issue of all the fields being treated as text
#It would have been a lot easier if they had APIs in place 
#to download the data, but it's not the case. API is available
#just for one of the datasets.
