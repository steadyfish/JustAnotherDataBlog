library(RSelenium)
library(rvest)
library(stringr)
###### scraping the API data #####

#alt-1
checkForServer() #download server
startServer()  #start the server
# -jar C:\Users\pokerface\R\win-library\3.2\RSelenium\bin\selenium-server-standalone.jar


rem_dr <- remoteDriver(browserName = "phantomjs")
rem_dr
rem_dr$open()

agreement_url = "https://www.frbservices.org/EPaymentsDirectory/agreement.html"
rem_dr$navigate(agreement_url)


btn = rem_dr$findElement(using = 'css selector', "button#agree_terms_use")
btn$getElementText()
rem_dr$mouseMoveToLocation(webElement = btn)
btn$clickElement()

lnk = rem_dr$findElement(using = "link text", "Download E-Payments Directories")
lnk$getElementText()
lnk$clickElement()
dnld_url = rem_dr$getCurrentUrl()

download_data = function(rem_dr, file_link_text, data_dict_link_text){
  #getting the data dictionary
  lnk = rem_dr$findElement(using = "link text", data_dict_link_text)
  lnk$getElementText()
  lnk$clickElement()
  
  
  tab = rem_dr$findElement(using = "css selector", "table#format-table")
  tableHTML <- tab$getElementAttribute("outerHTML")[[1]]
  d_dict = read_html(x = tableHTML) %>%
    html_table() %>%
    as.data.frame()
  
  names(d_dict) = tolower(str_replace_all(string = names(d_dict), pattern = "[. ]", replacement = "_"))
  
  d_dict$field_name_fmt = d_dict$field_name %>%
    str_replace_all("[. ]", "_") %>%
    tolower()
  
  # getting the routing numbers file
  rem_dr$goBack()
  lnk = rem_dr$findElement(using = "link text", file_link_text)
  rem_dr$executeScript("arguments[0].setAttribute('target', arguments[1]);", list(lnk, ""));
  lnk$getElementText()
  lnk$clickElement()
  
  d_txt = rem_dr$getPageSource()
  d_txt1 = rem_dr$findElement(using = "css selector", "pre")
  d_txt2 = d_txt1$getElementText()[[1]]
  
  d_txt3 = read.fwf(file = textConnection(d_txt2), #http://www.fededirectory.frb.org/FedACHdir.txt
                    widths = d_dict$length,
                    comment.char="",
                    colClasses = "character")
  
  names(d_txt3) = d_dict$field_name_fmt
  rem_dr$goBack()
  
  return(list(d_txt = d_txt3,
              d_dict = d_dict))
  
}

l_fedACH = download_data(rem_dr, "Receive All FedACH Participant RDFIs with commercial receipt volume", "View the FedACH Directory File Format only")
l_fedWIRE = download_data(rem_dr, "Receive All Fedwire Participants", "View the Fedwire Directory File Format only")





rem_dr$getCurrentUrl()
rem_dr$screenshot(display = TRUE)

rem_dr$close()

#output
write.csv(l_fedACH$d_txt, "Data/usa_bank_routing_numbers.csv")
write.csv(l_fedACH$d_dict, "Data/usa_bank_routing_numbers_data_dictionary.csv")

write.csv(l_fedWIRE$d_txt, "Data/usa_bank_wire_routing_numbers.csv")
write.csv(l_fedWIRE$d_dict, "Data/usa_bank_wire_routing_numbers_data_dictionary.csv")
