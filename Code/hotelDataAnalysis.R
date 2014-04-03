w_dir = getwd()
source(file=file.path(w_dir,"Code/Core.R"))
checkAndDownload(c("ggplot2","plyr","sqldf","sp"))

load(file=file.path(w_dir,"Data/hotelData.RData"))

################## Data Cleaning  #################
hotelData$id = as.numeric(hotelData$id)
hotelData$rooms = as.numeric(hotelData$rooms)
hotelData$state = trim(hotelData$state) #trimming leading and trailing spaces
hotelData$state = as.factor(hotelData$state)
hotelData$type = as.factor(hotelData$type)


################# Data Manipulation #################

#get the state codes file
#(data dictionary with indian states mapped to a 2 letter state code)
stateCodes <- read.table(
  file=file.path(w_dir,"Data/IndiaStateCodes.csv"),
  header=TRUE,
  sep=",",
  as.is=TRUE)

hotel_stateCodes <- sqldf("select a.*,b.* from stateCodes as a 
                          inner join hotelData as b on a.State_Caps = b.state")

#summarise hotel_stateCodes at state level
hotel_stateSummary <- ddply(hotel_stateCodes, .(Code), summarise,
                            count = length(Code)
                            )

#get the nation-wide map data with state boundaries using sp package
con <- url("http://biogeo.ucdavis.edu/data/gadm2/R/IND_adm1.RData")
load(con)
close(con)

states <- as.data.frame(gadm@data$NAME_1)
colnames(states) ="State_gadm"
states_stateCodes <- sqldf("select a.*,b.* from states as a 
                           left join stateCodes as b on a.State_gadm = b.State")

hotel_states <- sqldf("select a.State_gadm, a.Code, b.count
                      from states_stateCodes as a 
                      left join hotel_stateSummary as b on a.Code = b.Code")
gadm <- spCbind(gadm,hotel_states)
#using ggplot

india <- fortify(gadm, region = "NAME_1")
names(india)
temp <- gadm@data
india.df <- sqldf("select a.* ,b.Code,b.count from india as a
                  left join temp as b on a.id = b.Name_1")
S_Code <- aggregate(cbind(long, lat) ~ Code, data=india.df, FUN=function(x)mean(range(x)))
S_Code <-ddply(india.df, .(Code), function(df) kmeans(df[,1:2], centers=1)$centers) 

#png(file="D:/JustAnotherDataBlog/Plots/FirstPost_PS_Pos_Nov_04_Ind_ggplot.png",width=500,height=400)

p <- ggplot(india.df,aes(long,lat)) + 
  geom_polygon(aes(group=group,fill=count),color='white') +
  #geom_text(data=S_Code,aes(long,lat,label=Code), size=2.5) +
  #geom_path(color="white") +
  coord_equal() +
  #scale_fill_brewer() + 
  ggtitle("India: Government recognized Hotels")
p  
#dev.off()

p

p = ggplot(hotelData) +
  geom_histogram(aes(factor(state)))


