#install.packages('mapdata')
install.packages('sp') 
install.packages('maptools')
install.packages('rgeos')
install.packages('RColorBrewer')
library('sp') # a package for spatial data
library('ggplot2')
library('plyr') #required for fortify which converts 'sp' data to polygons data to be used with ggplot2
library('rgeos') #required for maptools
library('maptools') #required for fortify - region
library('sqldf')
library('RColorBrewer')

#get the nation-wide map data with state boundaries
con <- url("http://biogeo.ucdavis.edu/data/gadm2/R/IND_adm1.RData")
load(con)
close(con)

#get the data from indian government data website about ___
nov04 <- read.table(
  file="http://data.gov.in/access-point-download-count?url=http://data.gov.in/sites/default/files/powerSupplyNov04.csv&nid=34321",
  header=TRUE,
  sep=",",
  as.is=TRUE)
power = nov04
#Adhoc Data cleaning
colnames(power)
colnames(power)[1] = "State"
colnames(power)[2] = "Demand"
colnames(power)[3] = "Supplies"
colnames(power)[4] = "Net Surplus"
colnames(power)
WB_Area <- 88752
Sikkim_Area <- 7096
Jharkhand_Area <-79714
WB_Sikkim_Prop <- WB_Area / (WB_Area + Sikkim_Area)
WB_Jharkhand_Prop <- WB_Area / (WB_Area + Jharkhand_Area)
#some more data cleaning
#1.West Bengal and Sikkim to be split in some ratio:ratio of areas
WB1 <- power[power[, "State" ]== "W  B + Sikkim" , -1] * WB_Sikkim_Prop
SK <- power[power[, "State" ]== "W  B + Sikkim" , -1] - WB1

#2.DVC numbers to be divided between Jharkhand and West Bengal: by ration of areas
WB2 <- power[power[, "State" ]== "DVC" , -1] * WB_Jharkhand_Prop
power[power[, "State" ]== "Jharkhand" , -1] <- power[power[, "State" ]== "Jharkhand" , -1] +
     power[power[, "State" ]== "DVC" , -1] - WB2

WB = WB1 + WB2
#3. Tripura: not present in some of the datasets
#4. Andaman and Nicobar, Lakshdweep not part of the analysis
power = rbind(power,cbind(State="West Bengal",WB),cbind(State="Sikkim",SK))


#get the state codes file
stateCodes <- read.table(
  file="D:/JustAnotherDataBlog/Data/IndiaStateCodes.csv",
  header=TRUE,
  sep=",",
  as.is=TRUE)

#merge power data with state codes file
power_stateCodes <- sqldf("select a.*,b.* from stateCodes as a inner join power as b on a.State = b.State")

#cross check
sum(power_stateCodes$Demand) == power[power[, "State" ]== "All India" , 2]
power_stateCodes$Net_check = power_stateCodes$Supplies - power_stateCodes$Demand
sum(power_stateCodes$Net_check - power_stateCodes$Net_Surplus)

#H P, 
#J & K, 
#Uttaranchal, 
#Chattisgarh, 
#Daman & Diu, 
#D.N. Haveli, 
#Pondicherry, 
#DVC, 
#Orissa, 
#W B + Sikkim
#Andaman and Nicobar
#Lakshdweep

as.data.frame(gadm)
gadm@data
states <- as.data.frame(gadm@data$NAME_1)
colnames(states) ="State_gadm"
states_stateCodes <- sqldf("select a.*,b.* from states as a 
                           left join stateCodes as b on a.State_gadm = b.State")

power_states <- sqldf("select a.State_gadm, a.Code, b.Demand,
                      b.Supplies, b.Net_Surplus from states_stateCodes as a 
                      left join power_stateCodes as b on a.Code = b.Code")
power_states$log_Deficit <- log(-power_states$Net_Surplus+1)
breaks = quantile(power_states$log_Deficit,na.rm=TRUE)
breaks = 1 - exp(breaks)
power_states$Severity = cut(power_states$Net_Surplus,breaks,include.lowest =TRUE)
#with(power_states,power_states[Code == 'MH',])
#crosscheck as we can't merge using name
sum(gadm@data$NAME_1==power_states$State_gadm)==nrow(gadm@data)

gadm <- spCbind(gadm,power_states)
plotclr <- rev(brewer.pal(length(levels(gadm@data$Severity)),"Blues"))
#using spplot
png(file="D:/JustAnotherDataBlog/Plots/FirstPost_PS_Pos_Nov_04_Ind_spplot.png",width=500,height=400)

spplot(gadm, "Severity",
       col.regions=plotclr
       ,main="India: Net Power Supply Position for Nov 2004 (MU)")#,       col="transparent")

dev.off()

#using ggplot

india <- fortify(gadm, region = "NAME_1")
#india.df <- join(india, gadm@data, by="NAME_1") doesn't work because id cols are different
names(india)
temp <- gadm@data
india.df <- sqldf("select a.* ,b.* from india as a
                  left join temp as b on a.id = b.Name_1")#it's not case sensitive
S_Code <- aggregate(cbind(long, lat) ~ Code, data=india.df, FUN=function(x)mean(range(x)))
S_Code <-ddply(india.df, .(Code), function(df) kmeans(df[,1:2], centers=1)$centers) 
png(file="D:/JustAnotherDataBlog/Plots/FirstPost_PS_Pos_Nov_04_Ind_ggplot.png",width=500,height=400)

p <- ggplot(india.df,aes(long,lat)) + 
  geom_polygon(aes(group=group,fill=Severity),color='white') +
  geom_text(data=S_Code,aes(long,lat,label=Code), size=2.5) +
  #geom_path(color="white") +
  coord_equal() +
  scale_fill_brewer() + 
  ggtitle("India: Net Power Supply Position for Nov 2004 (MU)")
p  
dev.off()
