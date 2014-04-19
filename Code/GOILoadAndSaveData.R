w_dir = getwd()
source(file=file.path(w_dir,"Code/GOIDataInput.R"))
checkAndDownload(c("XML","RCurl","RJSONIO","plyr"))

#get the resource list file
#(it has resource names and resource ids used for the API call)
resourceList = read.table(
  file=file.path(w_dir,"Data/goi_api_resource_details.csv"),
  header=TRUE,
  sep=",",
  as.is=TRUE)

api_key = read.table(
  file=file.path(w_dir,"Data/goi_api_key_do_not_share.csv"),
  header=TRUE,
  sep=",",
  as.is=TRUE)

res = subset(resourceList, resource_name == "hotels")
hotelDetails = acquire_x_alldata(x = res[1], res_id = res[2], api_key = api_key)

res = subset(resourceList, resource_name == "pincode")
pincodeDetails = acquire_x_alldata(x = res[1], res_id = res[2], api_key = api_key)

res = subset(resourceList, resource_name == "commodities")
commoditiesDetails = acquire_x_alldata(x = res[1], res_id = res[2], api_key = api_key)

save(hotelDetails, file=file.path(w_dir,"Data/hotelDetails.RData"))

save(pincodeDetails, file=file.path(w_dir,"Data/pincodeDetails.RData"))

save(commoditiesDetails, file=file.path(w_dir,"Data/commoditiesDetails.RData"))