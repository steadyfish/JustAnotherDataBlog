library(plyr)
library(dplyr)
library(lubridate)
library(stringr)
library(xml2)
library(rvest)
library(tidyr)

d_bank = read.csv("Data/usa_bank_routing_numbers.csv", colClasses = "character")
d_bank_wire = read.csv("Data/usa_bank_wire_routing_numbers.csv", colClasses = "character")

d_dict = read.csv("Data/usa_bank_routing_numbers_data_dictionary.csv", colClasses = "character")
d_dict_wire = read.csv("Data/usa_bank_wire_routing_numbers_data_dictionary.csv", colClasses = "character")

table(d_bank$office_code)
table(d_bank$servicing_frb_number)
table(d_bank$record_type_code)


d_bank1 = d_bank %>%
  mutate(update_date = mdy(change_date, tz = "America/New_York"),
         
         current_routing_number1 = ifelse(record_type_code %in% 2, new_routing_number, routing_number),
         old_routing_number1 = ifelse(record_type_code %in% 2, routing_number, NA),
         
         current_routing_number = ifelse(new_routing_number != "000000000", new_routing_number, routing_number),
         old_routing_number = ifelse(new_routing_number == "000000000", "000000000", routing_number),
         
         customer_name_trim = str_trim(customer_name, side = "both"),
         address_trim = str_trim(address, side = "both"),
         city_trim = str_trim(city, side = "both"),
         zipcode_trim = str_trim(zipcode, side = "both"),
         zipcode_extn_trim = str_trim(zipcode_extension, side = "both")
  )

# do a TF-IDF on bank names to cluster together similar bank names
d_bank_names = d_bank1 %>% 
  select(X, customer_name_trim)

len = max(str_count(string = d_bank_names$customer_name_trim, pattern = " "))
vec_names = paste0("X", 1:(len + 1))

d_bank_names1 = d_bank_names %>%
  separate(col = "customer_name_trim", into = vec_names, sep = " ", extra = "drop") %>%
  gather(key = position, value = text, X1:X10, na.rm = TRUE) %>%
  mutate(text = str_trim(text, side = "both")) %>%
  filter(!text %in%  c("", "-", "&")) %>%
  group_by(X, text) %>%
  mutate(presence = n()) 

d_bank_names2  = d_bank_names1 %>%
  # select(-position) %>%
  spread(key = text, value = presence)

library(tm)
library(proxy)
c_bank_names = Corpus(x = VectorSource(d_bank_names$customer_name_trim) )
meta(c_bank_names, "id") = d_bank_names$X

# remove punctuation symbols
# get all the punctuation symbols UseMethod
# get all the records where there's sme punctuation is involved
# remove those specific punctuation characters
# don't remove english stopwords

c_bank_names1 = c_bank_names %>%
  tm_map(removePunctuation) %>%
  # tm_map(removeWords, stopwords("english")) %>%
  tm_map(stripWhitespace)

#dimension reduction - before/after DTM creation?


dtm = DocumentTermMatrix(c_bank_names1, control = list(weighting = function(x) weightTfIdf(x)))

dtm1 = dtm %>%
  removeSparseTerms(0.1)

## analysis
findFreqTerms(dtm1, 1)
a = findAssocs(dtm, "american",0.1)

### k-means (this uses euclidean distance)
m <- as.matrix(dtm)

### don't forget to normalize the vectors so Euclidean makes sense
norm_eucl <- function(m) m/apply(m, MARGIN=1, FUN=function(x) sum(x^2)^.5)
m_norm <- norm_eucl(m[1:1000, 1:1000])


### cluster into 10 clusters
cl <- kmeans(m_norm, 2)
cl

table(cl$cluster)

### show clusters using the first 2 principal components
plot(prcomp(m_norm)$x, col=cl$cl)

findFreqTerms(dtm[cl$cluster==1], 50)
inspect(reuters[which(cl$cluster==1)])


b = dist(as.matrix(dtm[1:1000, 1:1000]), method = "Euclidean")


# References:
# https://cran.r-project.org/web/packages/tm/vignettes/tm.pdf

## questions that can be answered
#1 on an average how many routing number updates are made a month or a year?
#2 which city, state highest number of banks registered
#3 which federal reserve bank has highest number of banks registered
#4 which bank has the most number of routing numbers

# do create routing numbers to banks database
# ach file format specification
agreement_url = "https://www.frbservices.org/EPaymentsDirectory/agreement.html"
agreement_html = read_html(agreement_url)

agreement_html %>% html_nodes("button#agree_terms_use") 

spec_html_url = "https://www.frbservices.org/EPaymentsDirectory/achFormat.html"
spec_html = read_html(spec_html_url)

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