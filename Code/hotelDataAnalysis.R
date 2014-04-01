w_dir = getwd()
source(file=file.path(w_dir,"Code/Core.R"))
checkAndDownload(c("ggplot2","plyr"))

load(file=file.path(w_dir,"Data/hotelData.RData"))

################## Data Cleaning and Manipulation ##############
hotelData$id = as.numeric(hotelData$id)
hotelData$rooms = as.numeric(hotelData$rooms)
hotelData$state = as.factor(hotelData$state)
hotelData$type = as.factor(hotelData$type)


p = ggplot(hotelData) +
  geom_histogram(aes(factor(state)))

p

