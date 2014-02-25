####Download the data from Government of India open data portal#####
w_dir = getwd()
source(file=file.path(w_dir,"Code/Core.R"))
checkAndDownload(c("XML","RCurl","RJSONIO","plyr"))

### Alternative - 1: Using APIs ###
#XML#
xmlURL = paste("http://data.gov.in/api/datastore/resource.xml?",
            "resource_id=5255d770-6cc9-44bc-befe-e65eff5b51e2",
            "&api-key=4a6b520b59fab36f4c78f8bac1a0afcf",
            "&limit=20",
            sep="")
hotelsContent = getURLContent(dataURL)
hotelsXMLDoc = xmlTreeParse(HotelsContent)

hotels = xmlToDataFrame(HotelsXML) #Doesn't work

top = xmlRoot(HotelsXMLDoc)
xmlName(top)
names(top)


#JSON#
getJSONDoc <- function(){
jsonURL = paste("http://data.gov.in/api/datastore/resource.json?",
                "resource_id=5255d770-6cc9-44bc-befe-e65eff5b51e2",
                "&api-key=4a6b520b59fab36f4c78f8bac1a0afcf",
                "&limit=3",
                sep="")
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


JSONList = getJSONDoc()

#get field type information, map to corresponding R fields

#list to dataframe
#0. Doesn't workeach row is a character vector
hotelsData = data.frame(matrix(getData(JSONList), nrow=getCount(JSONList), byrow=T))
#names(hotelsData) = getFieldNames(JSONList)

#1. Doesn't work:Final dataframe is a transposed and block diagonal version
hotelsData1 = ldply(getData(JSONList),data.frame)

#2. return value is a matrix, all the cells are text
tt = getData(JSONList)
t = lapply(tt, t)#, stringsAsFactors = FALSE)
hotelData2 = do.call(rbind,t)


#3.return value is a data.frame, all the cells are text
hotelData3 = ldply(lapply(getData(JSONList),t),data.frame, stringsAsFactors = FALSE)


#to do or next commit:
#1 use one of hotelData2, hotelData3 going forward
#2 try is there s an easy, better way of doing these conversion from list to a data.table
#3 resolve the issue of all the feilds being treated as text
#It would have been a lot easier if they had APIs in place 
#to download the data, but it's not the case. API is available
#just for one of the datasets.
