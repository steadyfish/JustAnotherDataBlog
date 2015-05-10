library(devtools)

install_github("steadyfish/ogdindiar")
library(ogdindiar)

api_key = read.table(
  file="Data/goi_api_key_do_not_share.csv",
  header=TRUE,
  sep=",",
  as.is=TRUE)

res_id = "60a68cec-7d1a-4e0e-a7eb-73ee1c7f29b7" #  "02fe6edc-ac46-435d-9e53-40806cbf175e"

a = fetch_data(res_id = res_id, api_key = api_key$api_key)
View(a[[1]])
View(a[[2]])

b = fetch_data(res_id = res_id, api_key = api_key$api_key, filter = c("state" = "Maharashtra", "id" = "9223"))
View(b[[1]])
View(b[[2]])

c = fetch_data(res_id = res_id, api_key = api_key$api_key, filter = c("state" = "Maharashtra", "id" = "9223"), select = c("name_of_member", "state"))
View(c[[1]])
View(c[[2]])

d = fetch_data(res_id = res_id, api_key = api_key$api_key, filter = c("state" = "Maharashtra"),
               select = c("s_no_","constituency"),
               sort = c("s_no_" = "asc","constituency" = "desc"))
View(d[[1]])
View(d[[2]])
