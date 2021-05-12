##############################################################
#plot global map together with barplots for historical reconstruction
##############################################################

library(ncdf4)
library(lattice)
library(ggplot2)
library(mapproj)
library(raster)
library(maptools)
library(rgdal)
library(plyr)
library(rworldmap)
library(sp)
library(methods)
library(TeachingDemos)
require(sp)
require(TeachingDemos)
require(RgoogleMaps)
library(grid)
library(dplyr)
library(rgeos)
library(plotrix)
library(smoothr)
library(abind)
library(sf)
library(stars)
library(rgeos)

#library(rmapshaper)
#library(ggmap)
#library(ggsubplot)
#library(rmapshaper)
#library(sp)
#library(ggvis)

list.files("/net/ch4/landclim/edavin/LUMIP/python/")

years_start_end = c(850, 2014) #850
all_seasons = c("JJA", "DJF") #, "ANN"
all_data_providers = c("D18", "B17")
all_scenarios = c("low", "high") #, *reg"

season = "JJA" #"JJA" or "DJF" or "ANN
data_provider = "D18" #B17, D18
scenario = "low" # low,high, reg

luc_masks_percentages <- c( 0.5, 0)

out_dir_barplots <- "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_plots/"


region_names <- c("North America", "Caribbean and Mesoamerica", "South America", "Central and Western Europe", "North Africa and Western Asia", "West, Central, East and South Africa", "Eastern Europe", "Central Asia, North-East and South Asia", "South East Asia", "Oceania")
region_numbers <- c(1,2,3,4,5,6,7,8,9,10)


conversions_only_3 <- c("DEF", "G2C", "CRO_R2I")
conversions_original_to_3 <- list(c("DBF2CRO" ,  "DBF2GRA" ,"DNF2CRO", "DNF2GRA", "EBF2CRO" ,"EBF2GRA",  "ENF2CRO", "ENF2GRA"), c("GRA2CRO"),c("CROr2CROi"))


all_seasons = c("JJA", "DJF") #, "ANN"
all_data_providers = c("D18", "B17")
all_scenarios = c("low", "high") #, *reg"

season = "JJA" #"JJA" or "DJF" or "ANN
#data_provider = "D18" #B17, D18
#scenario = "low" # low,high, reg

luc_masks_percentages <- c( 0.5, 0)
k=1

list.files("/net/ch4/landclim/schwabj/data/tmp_edouard_lumip/")

# df_JJA_D18_low <- read.table(paste("/net/ch4/landclim/schwabj/data/tmp_edouard_lumip/temporal_mean_IPBES_regions_", "JJA" , "_", "D18" ,"_", "low","_",luc_masks_percentages[k], ".csv", sep=""))
# df_JJA_B17_low <- read.table(paste("/net/ch4/landclim/schwabj/data/tmp_edouard_lumip/temporal_mean_IPBES_regions_", "JJA" , "_", "B17" ,"_", "low","_",luc_masks_percentages[k], ".csv", sep=""))

df_JJA_D18_low <- read.table(paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_trends_regions/temporal_mean_IPBES_regions_", "JJA" , "_", "D18" ,"_", "low","_",luc_masks_percentages[k],"_new_irrigation_new", ".csv", sep=""))
df_JJA_B17_low <- read.table(paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_trends_regions/temporal_mean_IPBES_regions_", "JJA" , "_", "B17" ,"_", "low","_",luc_masks_percentages[k],"_new_irrigation_new", ".csv", sep=""))

df_JJA_D18_high <- read.table(paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_trends_regions/temporal_mean_IPBES_regions_", "JJA" , "_", "D18" ,"_", "high","_",luc_masks_percentages[k],"_new_irrigation_new.csv", sep=""))
df_JJA_B17_high <- read.table(paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_trends_regions/temporal_mean_IPBES_regions_", "JJA" , "_", "B17" ,"_", "high","_",luc_masks_percentages[k],"_new_irrigation_new.csv", sep=""))

df_DJF_D18_low <- read.table(paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_trends_regions/temporal_mean_IPBES_regions_", "DJF" , "_", "D18" ,"_", "low","_",luc_masks_percentages[k], "_new_irrigation_new",".csv", sep=""))
df_DJF_B17_low <- read.table(paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_trends_regions/temporal_mean_IPBES_regions_", "DJF" , "_", "B17" ,"_", "low","_",luc_masks_percentages[k], "_new_irrigation_new",".csv", sep=""))


df_DJF_D18_high <- read.table(paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_trends_regions/temporal_mean_IPBES_regions_", "DJF" , "_", "D18" ,"_", "high","_",luc_masks_percentages[k], "_new_irrigation_new",".csv", sep=""))
df_DJF_B17_high <- read.table(paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_trends_regions/temporal_mean_IPBES_regions_", "DJF" , "_", "B17" ,"_", "high","_",luc_masks_percentages[k], "_new_irrigation_new",".csv", sep=""))

#choose the way of calculating the "uncertainty"
cum_sum_low_high = TRUE




######################################################################################################
#accumulated sums JJA
######################################################################################################


# str(df_JJA_D18_low)
# names(df_JJA_D18_low)
# as.numeric(df_JJA_D18_low[df_JJA_D18_low$conversions == "CRO_R2I" & df_JJA_D18_low$continents == "South East Asia", ])
# df_JJA_D18_low[df_JJA_D18_low$conversions == "CRO_R2I" & df_JJA_D18_low$continents == "South East Asia", "X1096"]
# 
# as.numeric(df_JJA_B17_low[df_JJA_B17_low$conversions == "CRO_R2I" & df_JJA_B17_low$continents == "South East Asia", ])
# df_JJA_B17_low[df_JJA_B17_low$conversions == "CRO_R2I" & df_JJA_B17_low$continents == "South East Asia", "X1096"]
# 
# as.numeric(df_JJA_D18_low[df_JJA_D18_low$conversions == "DEF" & df_JJA_D18_low$continents == "South East Asia", ])
# df_JJA_D18_low[df_JJA_D18_low$conversions == "DEF" & df_JJA_D18_low$continents == "South East Asia", "X1096"]
# 
# str(df_JJA_B17_low)
# str(df_JJA_D18_low)




for(season in all_seasons)
{

  print(season)
  
  if(season == "DJF")
  {
  df_JJA_D18_low <- df_DJF_D18_low
  df_JJA_B17_low <- df_DJF_B17_low

  df_JJA_D18_high <- df_DJF_D18_high
  df_JJA_B17_high <- df_DJF_B17_high
  }
  
  # data <- c(1, 2, 1, 3, 3, 4, 1, 2, 1)
  # mat = matrix(data, ncol=3)
  # df <- as.data.frame(mat)
  # t(apply(df, 1, cumsum))

if(cum_sum_low_high == TRUE)
{
df_JJA_D18_low[,3:dim(df_JJA_D18_low)[2]] <- t(apply(df_JJA_D18_low[,3:dim(df_JJA_D18_low)[2]], 1, cumsum))
df_JJA_B17_low[,3:dim(df_JJA_B17_low)[2]] <- t(apply(df_JJA_B17_low[,3:dim(df_JJA_B17_low)[2]], 1, cumsum))
}

df_JJA_low <- df_JJA_D18_low
#df_JJA_low[,3:dim(df_JJA_low)[2]] <- (df_JJA_D18_low[,3:dim(df_JJA_D18_low)[2]] + df_JJA_B17_low[,3:dim(df_JJA_B17_low)[2]] ) /2

temp_array <- abind(df_JJA_D18_low[,3:dim(df_JJA_D18_low)[2]], df_JJA_B17_low[,3:dim(df_JJA_B17_low)[2]], along=3)

#res <- apply(temp_array, 1:2, min)

# for(jj in 1:30)
# {
#   
#   if(df_JJA_D18_low[jj,dim(df_JJA_D18_low)[2]] >  df_JJA_B17_low[jj,dim(df_JJA_B17_low)[2]])
#   {
#     df_JJA_low[jj, ] <- df_JJA_B17_low[jj,]
#   }
# 
# }

#temp_array[1, 1165,1]
#temp_array[1, 1165,2]

#df_JJA_low[,3:dim(df_JJA_low)[2]] <-  res



# df_JJA_D18_high <- read.table(paste("/net/ch4/landclim/schwabj/data/tmp_edouard_lumip/temporal_mean_IPBES_regions_", "JJA" , "_", "D18" ,"_", "high","_",luc_masks_percentages[k],".csv", sep=""))
# df_JJA_B17_high <- read.table(paste("/net/ch4/landclim/schwabj/data/tmp_edouard_lumip/temporal_mean_IPBES_regions_", "JJA" , "_", "B17" ,"_", "high","_",luc_masks_percentages[k],".csv", sep=""))

if(cum_sum_low_high == TRUE)
{
df_JJA_D18_high[,3:dim(df_JJA_D18_high)[2]] <- t(apply(df_JJA_D18_high[,3:dim(df_JJA_D18_high)[2]], 1, cumsum))
df_JJA_B17_high[,3:dim(df_JJA_B17_high)[2]] <- t(apply(df_JJA_B17_high[,3:dim(df_JJA_B17_high)[2]], 1, cumsum))
}

df_JJA_high <- df_JJA_D18_high

#df_JJA_high[,3:dim(df_JJA_high)[2]] <- (df_JJA_D18_high[,3:dim(df_JJA_D18_high)[2]] + df_JJA_B17_high[,3:dim(df_JJA_B17_high)[2]] ) /2

temp_array <- abind(df_JJA_D18_high[,3:dim(df_JJA_D18_high)[2]], df_JJA_B17_high[,3:dim(df_JJA_B17_high)[2]], along=3)
dim(temp_array)
#res <- apply(temp_array, c(1,2), max)

# for(jj in 1:30)
# {
#   
#   if(df_JJA_D18_high[jj,dim(df_JJA_D18_high)[2]] <  df_JJA_B17_high[jj,dim(df_JJA_B17_high)[2]])
#   {
#     df_JJA_high[jj, ] <- df_JJA_B17_high[jj,]
#   }
#   
# }

temp_array <- abind(df_JJA_D18_low[,3:dim(df_JJA_D18_low)[2]], df_JJA_B17_low[,3:dim(df_JJA_B17_low)[2]], df_JJA_D18_high[,3:dim(df_JJA_D18_high)[2]], df_JJA_B17_high[,3:dim(df_JJA_B17_high)[2]], along=3)
res <- apply(temp_array, 1:2, min)
df_JJA_low[,3:dim(df_JJA_low)[2]] <-  res

temp_array <- abind(df_JJA_D18_low[,3:dim(df_JJA_D18_low)[2]], df_JJA_B17_low[,3:dim(df_JJA_B17_low)[2]], df_JJA_D18_high[,3:dim(df_JJA_D18_high)[2]], df_JJA_B17_high[,3:dim(df_JJA_B17_high)[2]], along=3)
res <- apply(temp_array, 1:2, max)
df_JJA_high[,3:dim(df_JJA_high)[2]] <-  res

str(df_JJA_D18_high)
as.numeric(df_JJA_D18_high[df_JJA_D18_high$conversions == "CRO_R2I" & df_JJA_D18_high$continents == "South East Asia", ])
df_JJA_D18_high[df_JJA_D18_high$conversions == "CRO_R2I" & df_JJA_D18_high$continents == "South East Asia", "X1096"]


# plot(as.numeric(df_JJA_D18_high[df_JJA_D18_high$conversions == "CRO_R2I" & df_JJA_D18_high$continents == "Central and Western Europe", ]), type = "l")
# plot(as.numeric(df_JJA_D18_low[df_JJA_D18_low$conversions == "CRO_R2I" & df_JJA_D18_low$continents == "Central and Western Europe", ]), type = "l")
# plot(as.numeric(df_JJA_B17_high[df_JJA_B17_high$conversions == "CRO_R2I" & df_JJA_B17_high$continents == "Central and Western Europe", ]), type = "l")
# plot(as.numeric(df_JJA_B17_low[df_JJA_B17_low$conversions == "CRO_R2I" & df_JJA_B17_low$continents == "Central and Western Europe", ]), type = "l")
#?png
png(file="/net/ch4/landclim/schwabj/data/LUMIP_Jonas/tmp_plots/temporal_trends_not_accumulated_western_europe.png")
par(mfrow=c(2,2))
plot(as.numeric(df_JJA_D18_high[df_JJA_D18_high$conversions == "G2C" & df_JJA_D18_high$continents == "Central and Western Europe", ]), type = "l", main="df_JJA_D18_high", ylab="delta T")
plot(as.numeric(df_JJA_D18_low[df_JJA_D18_low$conversions == "G2C" & df_JJA_D18_low$continents == "Central and Western Europe", ]), type = "l", main="df_JJA_D18_low", ylab="delta T")
plot(as.numeric(df_JJA_B17_high[df_JJA_B17_high$conversions == "G2C" & df_JJA_B17_high$continents == "Central and Western Europe", ]), type = "l", main="df_JJA_B17_high", ylab="delta T")
plot(as.numeric(df_JJA_B17_low[df_JJA_B17_low$conversions == "G2C" & df_JJA_B17_low$continents == "Central and Western Europe", ]), type = "l", main="df_JJA_B17_low", ylab="delta T")
dev.off()

png(file="/net/ch4/landclim/schwabj/data/LUMIP_Jonas/tmp_plots/temporal_trends_DEF_accumulated_western_europe.png")
par(mfrow=c(2,2))
plot(as.numeric(df_JJA_D18_high[df_JJA_D18_high$conversions == "DEF" & df_JJA_D18_high$continents == "Central and Western Europe", ]), type = "l", main="df_JJA_D18_high", ylab="delta T", col="red", ylim=c(0,0.5))
lines(as.numeric(df_JJA_B17_high[df_JJA_B17_high$conversions == "DEF" & df_JJA_B17_high$continents == "Central and Western Europe", ]), type = "l", main="df_JJA_B17_high", ylab="delta T", col="red")
lines(as.numeric(df_JJA_D18_low[df_JJA_D18_low$conversions == "DEF" & df_JJA_D18_low$continents == "Central and Western Europe", ]), type = "l", main="df_JJA_D18_low", ylab="delta T", col="blue")
lines(as.numeric(df_JJA_B17_low[df_JJA_B17_low$conversions == "DEF" & df_JJA_B17_low$continents == "Central and Western Europe", ]), type = "l", main="df_JJA_B17_low", ylab="delta T", col="blue")
dev.off()


png(file="/net/ch4/landclim/schwabj/data/LUMIP_Jonas/tmp_plots/temporal_trends_western_europe.png")
par(mfrow=c(2,2))
plot(cumsum(na.omit(as.numeric(df_JJA_D18_high[df_JJA_D18_high$conversions == "G2C" & df_JJA_D18_high$continents == "Central and Western Europe", 3:1167]))), type = "l", main="df_JJA_D18_high", ylab="delta T")
plot(cumsum(na.omit(as.numeric(df_JJA_D18_low[df_JJA_D18_low$conversions == "G2C" & df_JJA_D18_low$continents == "Central and Western Europe", ]))), type = "l", main="df_JJA_D18_low", ylab="delta T")
plot(cumsum(na.omit(as.numeric(df_JJA_B17_high[df_JJA_B17_high$conversions == "G2C" & df_JJA_B17_high$continents == "Central and Western Europe", ]))), type = "l", main="df_JJA_B17_high", ylab="delta T")
plot(cumsum(na.omit(as.numeric(df_JJA_B17_low[df_JJA_D18_high$conversions == "G2C" & df_JJA_D18_high$continents == "Central and Western Europe", ]))), type = "l", main="df_JJA_B17_low", ylab="delta T")
dev.off()

#cbind(df_JJA_D18_high[df_JJA_D18_high$conversions == "G2C" & df_JJA_D18_high$continents == "Central and Western Europe", 3:1167] , df_JJA_B17_high[df_JJA_B17_high$conversions == "G2C" & df_JJA_B17_high$continents == "Central and Western Europe", 3:1167])
#cumsum(as.numeric(df_JJA_D18_high[df_JJA_D18_high$conversions == "CRO_R2I" & df_JJA_D18_high$continents == "Central and Western Europe", ]), na.rm=T)
#res <- apply(temp_array, c(1,2), max)
which(df_JJA_D18_high$conversions == "G2C" & df_JJA_D18_high$continents == "Central and Western Europe")

png(file="/net/ch4/landclim/schwabj/data/LUMIP_Jonas/tmp_plots/temporal_trends_high_combined_then_accumulated_western_europe.png")
plot(cumsum(na.omit(as.numeric(res[14,]))), type = "l", main="high combined then accumulated", ylab="delta T")
dev.off()

png(file="/net/ch4/landclim/schwabj/data/LUMIP_Jonas/tmp_plots/temporal_trends_high_combined_western_europe.png")
plot(na.omit(as.numeric(res[14,])), type = "l", main="high combined not accumulated", ylab="delta T")
dev.off()




#df_JJA_high[,3:dim(df_JJA_high)[2]] <- res

df_mean_JJA <- df_JJA_D18_low
df_mean_JJA[,3:dim(df_mean_JJA)[2]] <- (df_JJA_D18_low[,3:dim(df_JJA_D18_low)[2]] + df_JJA_B17_low[,3:dim(df_JJA_B17_low)[2]] + df_JJA_D18_high[,3:dim(df_JJA_D18_high)[2]] + df_JJA_B17_high[,3:dim(df_JJA_B17_high)[2]]) /4

df_mean_JJA_melted <- reshape2::melt(df_mean_JJA)


df_JJA_high_melted <- reshape2::melt(df_JJA_high)
df_JJA_low_melted <- reshape2::melt(df_JJA_low)

# p <- ggplot(df_JJA_high_melted[df_JJA_high_melted$continents == "north_america" & df_JJA_high_melted$conversions == "DEF",]) + geom_line(aes(y=value, x=variable))
# p

df_JJA_high_low <- df_JJA_low_melted

df_JJA_high_low$variable <- as.numeric(substring(as.character(df_JJA_high_low$variable), 2))

df_JJA <- df_JJA_high_low[,1:3]
df_JJA$low <- df_JJA_low_melted[,4]
df_JJA$high <- df_JJA_high_melted[,4]

df_JJA$mean <- df_mean_JJA_melted$value

summary(df_JJA$high-df_JJA$low)
str(df_JJA)


df_JJA_irrigation <- df_JJA[df_JJA$conversions == "CRO_R2I", ]
str(df_JJA_irrigation)

low_SEA <- cumsum( df_JJA_irrigation[df_JJA_irrigation$continents == "South East Asia", "low"])
high_SEA <- cumsum( df_JJA_irrigation[df_JJA_irrigation$continents == "South East Asia", "high"])

plot(low_SEA, type="l")
lines(high_SEA)

plot(df_JJA_irrigation[df_JJA_irrigation$continents == "South East Asia", "low"], type="l")
lines(df_JJA_irrigation[df_JJA_irrigation$continents == "South East Asia", "high"], col="red")





#@@@@@@@@@@@@@@@@@@@@@@@@@
#JJA region specific plot

#region="Central Asia, North-East and South Asia" #"Caribbean and Mesoamerica", "Central and Western Europe", "Central Asia, North-East and South Asia", "Eastern Europe",   "North Africa and Western Asia" ,  "North America", "Oceania",  "South America",  "South East Asia", "West, Central, East and South Africa"

regions = c("Caribbean and Mesoamerica", "Central and Western Europe", "Central Asia, North-East and South Asia", "Eastern Europe",   "North Africa and Western Asia" ,  "North America", "Oceania",  "South America",  "South East Asia", "West, Central, East and South Africa")


for(i in 1:length(regions))
{
  region = regions[i]
  print(region)
  
  df_JJA_region <- df_JJA[df_JJA$continents == paste(region),]
  str(df_JJA_region)
  
  p <- ggplot(df_JJA_region) + geom_line(aes(y=high, x=variable, color=conversions))
  p
  p <- ggplot(df_JJA_region) + geom_point(aes(y=high, x=variable, color=conversions))
  p
  p <- ggplot(df_JJA_region) + geom_point(aes(y=low, x=variable, color=conversions))
  p
  
  
  df_JJA_region$cum_sum_low <- NA
  df_JJA_region$cum_sum_mean <- NA
  df_JJA_region$cum_sum_high <- NA
  
  
  if(cum_sum_low_high == FALSE)
  {
  df_JJA_region[df_JJA_region$conversions =="DEF", "cum_sum_low"] <- cumsum( df_JJA_region[df_JJA_region$conversions =="DEF", "low"])
  df_JJA_region[df_JJA_region$conversions =="DEF", "cum_sum_mean"] <- cumsum( df_JJA_region[df_JJA_region$conversions =="DEF", "mean"])
  df_JJA_region[df_JJA_region$conversions =="DEF", "cum_sum_high"] <- cumsum( df_JJA_region[df_JJA_region$conversions =="DEF", "high"])
  
  df_JJA_region[df_JJA_region$conversions =="G2C", "cum_sum_low"] <- cumsum( df_JJA_region[df_JJA_region$conversions =="G2C", "low"])
  df_JJA_region[df_JJA_region$conversions =="G2C", "cum_sum_mean"] <- cumsum( df_JJA_region[df_JJA_region$conversions =="G2C", "mean"])
  df_JJA_region[df_JJA_region$conversions =="G2C", "cum_sum_high"] <- cumsum( df_JJA_region[df_JJA_region$conversions =="G2C", "high"])
  
  df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "cum_sum_low"] <- cumsum( df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "low"])
  df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "cum_sum_mean"] <- cumsum( df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "mean"])
  df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "cum_sum_high"] <- cumsum( df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "high"])
  } else{
    df_JJA_region[df_JJA_region$conversions =="DEF", "cum_sum_low"] <-df_JJA_region[df_JJA_region$conversions =="DEF", "low"]
    df_JJA_region[df_JJA_region$conversions =="DEF", "cum_sum_mean"] <- df_JJA_region[df_JJA_region$conversions =="DEF", "mean"]
    df_JJA_region[df_JJA_region$conversions =="DEF", "cum_sum_high"] <-  df_JJA_region[df_JJA_region$conversions =="DEF", "high"]
    
    df_JJA_region[df_JJA_region$conversions =="G2C", "cum_sum_low"] <-  df_JJA_region[df_JJA_region$conversions =="G2C", "low"]
    df_JJA_region[df_JJA_region$conversions =="G2C", "cum_sum_mean"] <-  df_JJA_region[df_JJA_region$conversions =="G2C", "mean"]
    df_JJA_region[df_JJA_region$conversions =="G2C", "cum_sum_high"] <- df_JJA_region[df_JJA_region$conversions =="G2C", "high"]
    
    df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "cum_sum_low"] <-  df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "low"]
    df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "cum_sum_mean"] <-  df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "mean"]
    df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "cum_sum_high"] <- df_JJA_region[df_JJA_region$conversions =="CRO_R2I", "high"]
  }
  
  
  
  
  
  #?aggregate
  df_agg_low = aggregate(cum_sum_low ~ variable + continents ,data=df_JJA_region, FUN=sum)
  df_agg <- df_agg_low
  df_agg$conversions = "total"
  
  
  
  
  df_agg_high <- aggregate(cum_sum_high ~ variable + continents ,data=df_JJA_region, FUN=sum)
  df_agg_mean <- aggregate(cum_sum_mean ~ variable + continents ,data=df_JJA_region, FUN=sum)
  
  df_agg$cum_sum_high <- df_agg_high$cum_sum_high
  df_agg$cum_sum_mean <- df_agg_mean$cum_sum_mean
  
  df_agg$low <- NA; df_agg$mean <- NA; df_agg$high <- NA
  
  str(df_agg)
  str(df_JJA_region)
  
  df_with_total <- rbind(df_JJA_region, df_agg)
  
  p <- ggplot(df_with_total) + geom_point(aes(y=cum_sum_mean, x=variable, color=conversions))
  p
  
  p <- ggplot(df_with_total) + geom_line(aes(y=cum_sum_low, x=variable, color=conversions), cex=1)  +  geom_line(aes(y=cum_sum_high, x=variable, color=conversions), cex=1)  +  geom_line(aes(y=cum_sum_mean, x=variable, group=conversions), linetype = "dashed")  + ylab("accumulated sum") + xlab("year") + ggtitle(paste(region, "JJA")) + scale_color_manual(values=c(  "blue","saddlebrown", "dark green", "grey")) + theme_bw(base_size = 20) + theme(plot.title = element_text(size = 16))
  p
  
  
  #df_with_total[df_with_total$conversions == "G2C", ][1100:1165, ]
  
  #print(p)
  
  #ggsave(paste(out_dir_barplots, "accumulated_sum_", region,  "_new_regions_low_high_JJA.png", sep="") , p, "png")
  
  #str(df_with_total)
  
  df_with_total$conversions <- as.factor(df_with_total$conversions)
  levels(df_with_total$conversions)  <- c("Irrigation", "Deforestation", "Grass to Crop", "Total")
df_with_total$conversions <-  factor(df_with_total$conversions, levels = c("Deforestation","Irrigation",  "Grass to Crop", "Total"))
  
  p <- ggplot(df_with_total) + geom_ribbon(aes(ymin=cum_sum_low,ymax=cum_sum_high , x=variable, fill=conversions),alpha=0.5, cex=1) + scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey")) +  geom_line(aes(y=cum_sum_mean, x=variable, group=conversions, color=conversions), linetype = "dashed") + ylab("accumulated sum") + xlab("year") + ggtitle(paste(region, season)) + scale_color_manual(values=c(  "saddlebrown","blue", "dark green", "black")) + theme_bw(base_size = 20) + theme(plot.title = element_text(size = 16))+ theme(legend.title = element_blank()) + ylab(expression(Delta*"T[K]")) + theme(legend.position = "none")
  p
  
  print(p)
  
  if(season == "DJF")
  { ggsave(paste(out_dir_barplots, "ribbon_accumulated_sum_", region,  "_new_regions_low_high_DJF.png", sep="") , p, "png")
  }else{
    ggsave(paste(out_dir_barplots, "ribbon_accumulated_sum_", region,  "_new_regions_low_high_JJA.png", sep="") , p, "png")  
  }
  
  if(i == 1)
  {
  p <- ggplot(df_with_total) + geom_ribbon(aes(ymin=cum_sum_low,ymax=cum_sum_high , x=variable, fill=conversions),alpha=0.5, cex=1) + scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey")) +  geom_line(aes(y=cum_sum_mean, x=variable, group=conversions, color=conversions), linetype = "dashed") + ylab("accumulated sum") + xlab("year") + ggtitle(paste(region, season)) + scale_color_manual(values=c(  "saddlebrown","blue", "dark green", "black")) + theme_bw(base_size = 20) + theme(plot.title = element_text(size = 16))+ theme(legend.title = element_blank()) + ylab(expression(Delta*"T[K]"))# + theme(legend.position = "none")
  print(p)
  
  ggsave(paste(out_dir_barplots, "ribbon_accumulated_sum_", region,  "_new_regions_low_high_JJA_with_legend.png", sep="") , p, "png")  
  }
  
  
  df_with_total[df_with_total$continents == "Central and Western Europe" & df_with_total$conversions == "Deforestation", "cum_sum_high"][1165]
  df_with_total[df_with_total$continents == "Central and Western Europe" & df_with_total$conversions == "Deforestation", "cum_sum_low"][1165]
  
}


}






