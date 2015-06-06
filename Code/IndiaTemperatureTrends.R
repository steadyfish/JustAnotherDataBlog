# ogdindiar sample analysis
library(devtools)
devtools::install_github("steadyfish/ogdindiar")
install.packages("dygraphs")
install.packages("magrittr")
install.packages("RColorBrewer")
install.packages("dplyr")
install.packages("tidyr")

library(ogdindiar)
library(xts)
library(dygraphs)
library(magrittr)
library(RColorBrewer)
library(dplyr)
library(tidyr)

your_api_key = read.table(
  file="Data/goi_api_key_do_not_share.csv",
  header=TRUE,
  sep=",",
  as.is=TRUE)

mean_temp_ls = fetch_data(res_id = "98fe9271-a59d-4834-b05b-fd5ddb94ac01",
                            api_key = your_api_key)

mean_temp_data = mean_temp_ls[[1]]

mean_temp_data %>% names
mean_temp_data %>% str

mean_temp_long = mean_temp_data %>%
  gather(key = quarter, value = seasonal, select = jan_feb:oct_dec) %>%
  mutate(quarter_num = ifelse(quarter %in% "jan_feb", "Q1",
                              ifelse(quarter %in% "mar_may", "Q2",
                                     ifelse(quarter %in% "jun_sep", "Q3", "Q4"))))

mean_temp_long$yr_qr = paste(mean_temp_long$year, mean_temp_long$quarter_num)

mean_temp_long %<>% 
  select(yr_qr, annual, seasonal)

mean_temp_xts = xts(x = mean_temp_data[ ,-c(1:3)], order.by = as.Date(mean_temp_data[ , 3] %>% as.character, format = "%Y"))

mean_temp_long %>% names
mean_temp_xts = xts(x = mean_temp_long[ , c(2:3)], order.by = as.yearqtr(mean_temp_long[ , 1]))

clr = RColorBrewer::brewer.pal(2, "Set1")

```{r, fig.width=6, fig.height=2.5}
dygraph(mean_temp_xts, main = "India Mean Temperatures", ylab = "Temp (C)") %>%
  dyOptions(colors = clr[1:2], 
            includeZero = TRUE) %>%
  dyRangeSelector(dateWindow = c("1980-01-01", "2012-01-01"))
```