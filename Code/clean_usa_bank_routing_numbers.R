library(plyr)
library(dplyr)
library(lubridate)
library(stringr)
library(xml2)
library(rvest)

d_bank = read.csv("Data/usa_bank_routing_numbers.csv", colClasses = "character")

d_dict = read.csv("Data/usa_bank_routing_numbers_data_dictionary.csv", colClasses = "character")

table(d_bank$office_code)
table(d_bank$servicing_frb_number)
table(d_bank$record_type_code)


d_bank1 = d_bank %>%
  mutate(update_date = mdy(change_date, tz = "America/New_York"),
         current_routing_number = ifelse(new_routing_number != "000000000", new_routing_number, routing_number),
         old_routing_number = ifelse(new_routing_number == "000000000", "000000000", routing_number),
         customer_name_trim = str_trim(customer_name, side = "both"),
         address_trim = str_trim(address, side = "both"),
         city_trim = str_trim(city, side = "both"),
         zipcode_trim = str_trim(zipcode, side = "both"),
         zipcode_extn_trim = str_trim(zipcode_extension, side = "both")
  )

# ach file format specification
agreement_url = "https://www.frbservices.org/EPaymentsDirectory/agreement.html"
agreement_html = read_html(agreement_url)

agreement_html %>% html_nodes("button#agree_terms_use") 

spec_html_url = "https://www.frbservices.org/EPaymentsDirectory/achFormat.html"
spec_html = read_html(spec_html_url)

# do create routing numbers to banks database
txt_data = read.fwf(file = url("https://www.frbservices.org/EPaymentsDirectory/FedACHdir.txt"), #http://www.fededirectory.frb.org/FedACHdir.txt
                    widths = c(9,26,36,36,20,2,5,16),
                    comment.char="",
                    colClasses = "character")
txt_data %>% str
names(txt_data) = c("routingaba", "p1", "bank_raw", "bankAddress", "bankCity", "bankState", "bankZip", "p2")

## clubbing similar banks together

table(txt_data$bank_raw) %>% as.data.frame() %>% arrange(desc(Freq)) %>% View

# removing period and comma
txt_data$bank1 = str_replace_all(string = txt_data$bank_raw,pattern = "[\\.,]",replacement = "")
# padding 2 spaces at the end
txt_data$bank2 = paste0(txt_data$bank1,"  ")
# replacing NA's at the end using 2 spaces padded above
txt_data$bank3 = str_replace_all(string = txt_data$bank2,pattern = fixed(" NA  "),replacement = "")
# trimming spaces from beginning and the end
txt_data$bank4 = str_trim(txt_data$bank3)


table(txt_data$bank1) %>% as.data.frame() %>% arrange(desc(Freq)) %>% View
table(txt_data$bank2) %>% as.data.frame() %>% arrange(desc(Freq)) %>% View
table(txt_data$bank3) %>% as.data.frame() %>% arrange(desc(Freq)) %>% View
table(txt_data$bank4) %>% as.data.frame() %>% arrange(desc(Freq)) %>% View


## save the final database
wdir = getwd()
saveRDS(object = txt_data,file = paste0(wdir,"/KPI/r_out/us_banks_routing_data.rds"))