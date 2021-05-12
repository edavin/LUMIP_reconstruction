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
#library(TeachingDemos)
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


list.files("/net/ch4/landclim/edavin/LUMIP/python/")

years_start_end = c(850, 2014) #850
#all_seasons = c("JJA", "DJF") #, "ANN"
all_seasons = c("DJF") #, "ANN"
#all_data_providers = c("D18", "B17")
all_data_providers = c("D18")
all_scenarios = c("low", "high") #, *reg"
#all_scenarios = c("high") #, *reg"

luc_masks_percentages <- c( 0.5) #c( 0.5, 0)

IPBES_regions_path <- "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/IPBES_raster_summarized_regions.tif"

output_dir = "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/temporal_trends_regions/"


########################
#create lulc mask
#read luc rasters
all_variables <- c("CROr2CROi", "DBF2CRO", "DBF2GRA", "DNF2CRO", "DNF2GRA", "EBF2CRO", "EBF2GRA", "ENF2CRO", "ENF2GRA", "GRA2CRO")
all_rasters <- list.files("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized/", full.names = T)  

all_luc_rasters <- raster::stack(c("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//CROr2CROi.tif", "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//DBF2CRO.tif" ,  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//DBF2GRA.tif" , "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//DNF2CRO.tif", "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//DNF2GRA.tif",  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//EBF2CRO.tif",  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//EBF2GRA.tif",  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//ENF2CRO.tif" , "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//ENF2GRA.tif" ,  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//GRA2CRO.tif" ))

names(all_luc_rasters) <- all_variables
plot(all_luc_rasters)
spplot(all_luc_rasters, main="luc sum")
mask_all_but_irri <- sum(all_luc_rasters[[c("DBF2CRO" ,  "DBF2GRA" ,  "DNF2CRO" ,  "DNF2GRA" ,  "EBF2CRO" ,  "EBF2GRA",   "ENF2CRO" ,  "ENF2GRA","GRA2CRO")]]) 
plot(mask_all_but_irri)
spplot(mask_all_but_irri)

mask_all_but_irri_threshold <- mask_all_but_irri
mask_all_but_irri_threshold[mask_all_but_irri_threshold < 0.5] <- NA
plot(mask_all_but_irri_threshold)

mask_only_irri <- all_luc_rasters[[c("CROr2CROi")]]
plot(mask_only_irri)
mask_only_irri_threshold <- mask_only_irri
mask_only_irri_threshold[mask_only_irri_threshold < 0.5] <- NA
plot(mask_only_irri_threshold)

mask_only_DEF <- sum(all_luc_rasters[[c("DBF2CRO" ,  "DBF2GRA" ,  "DNF2CRO" ,  "DNF2GRA" ,  "EBF2CRO" ,  "EBF2GRA",   "ENF2CRO" ,  "ENF2GRA")]]) 
plot(mask_only_DEF)
spplot(mask_only_DEF)

mask_only_GRA2CRO <- all_luc_rasters[[c("GRA2CRO")]]
plot(mask_only_GRA2CRO)
spplot(mask_only_GRA2CRO)


#load IPBES regions as grid
IPBES_sub <- raster(paste(IPBES_regions_path))
plot(IPBES_sub)
IPBES_sub_copy <- IPBES_sub

for(k in 1:length(luc_masks_percentages))
{
  print(paste("k:", k))
  print(paste("luc_masks_percentages: ", luc_masks_percentages[k]))
  
  for(season in all_seasons)
  {
    print(season)
    for(data_provider in all_data_providers)
    {
      print(data_provider)
      for(scenario in all_scenarios)
      {
        print(scenario)
        
        #ncin <- nc_open(paste("/net/ch4/landclim/edavin/LUMIP/python/old_netcdf/", "TS_LUH2_", scenario,"_", data_provider,"_", season, ".nc", sep=""))
        ncin <- nc_open(paste("/net/ch4/landclim/edavin/LUMIP/python/", "TSrec_", scenario,"_", data_provider,"_", season, ".nc", sep=""))
        
        
        print(ncin)
        print(ncvar_get(ncin, "time"))
        start_value_time = length(ncvar_get(ncin, "time")) - (years_start_end[2]- years_start_end[1])
        print(ncvar_get(ncin, "conversion"))
        #get lon and lat
        lon <- ncvar_get(ncin, "lon"); nlon <- dim(lon); head(lon); lat <- ncvar_get(ncin, "lat", verbose = F); 
        nlat <- dim(lat); head(lat); print(c(nlon, nlat))
        #grid <- expand.grid(lon = lon, lat = lat)
        
        #this is the full data set:
        
        system.time(TS_array <- ncvar_get(ncin, varid = paste("TSrec"), start=c(start_value_time, 1,1,1))) 
        #system.time(TS_array <- ncvar_get(ncin, varid = paste("TSrec"), start=c(1100, 1,1,1))) pprox 1-2 minutes
        #system.time(TS_array <- ncvar_get(ncin, varid = paste("TS_" , data_provider, "_", scenario, sep=""), start=c(start_value_time, 1,1,1), count=c(1164, 1440,720,1))) #approx 30-60 seconds
        #system.time(TS_array <- ncvar_get(ncin, varid = paste("TS_" , data_provider, "_", scenario, sep=""), start=c(start_value_time, 1,1,1), count=c(50, 1440,720,10)))
        #system.time((TS_array_time_period <- TS_B17_high_DJF_array[ncvar_get(ncin, "time") %in% seq(years_start_end[1], years_start_end[2], 1) ,,,])
        #TS_B17_high_array_time_period_sum <- base::rowSums(DTS_B17_high_array_time_period, dims=2)
        
        TS_array_time_period <- TS_array
        
        
        #combine continents and regions ########################################
        conversions = c("CROr2CROi", "DBF2CRO" ,  "DBF2GRA" ,  "DNF2CRO" ,  "DNF2GRA" ,  "EBF2CRO" ,  "EBF2GRA",   "ENF2CRO" ,  "ENF2GRA" ,  "GRA2CRO")
        
        r_tmp <- colSums(TS_array_time_period[,,, which(ncvar_get(ncin, "conversion") == paste(conversions[1]))], na.rm=T, dims=1)
        r_tmp <- raster(t(matrix(r_tmp, nrow=1440)), xmn=-180, xmx=180, ymn=-90, ymx=90)
        crs(r_tmp) <- CRS("+init=epsg:4326")
        plot(r_tmp)
        
        # r_tmp_01 <- TS_array_time_period[1, , ,1]
        # r_tmp_01 <- raster(t(matrix(r_tmp_01, nrow=1440)), xmn=-180, xmx=180, ymn=-90, ymx=90)
        # plot(r_tmp_01)
        # 
        # r_tmp <- colSums(TS_array_time_period[,,], na.rm=T, dims=1)
        # r_tmp <- raster(t(matrix(r_tmp, nrow=1440)), xmn=-180, xmx=180, ymn=-90, ymx=90)
        # crs(r_tmp) <- CRS("+init=epsg:4326")
        # plot(r_tmp)
        # 
        # r_tmp_01 <- TS_array_time_period[1000, , ]
        # r_tmp_01 <- raster(t(matrix(r_tmp_01, nrow=1440)), xmn=-180, xmx=180, ymn=-90, ymx=90)
        # plot(r_tmp_01)
        
        
        
        
        ################################
        #temporal analysis/plots
        ################################
        
        str(TS_array_time_period)
        dim(TS_array_time_period)
        
        
        #data frame for results #########################################
        df_all_conversions_per_continents_and_year <- data.frame(matrix(rep(NA, 10 * 3 * (dim(TS_array_time_period)[1] + 2)), ncol=dim(TS_array_time_period)[1] + 2))
        
        names(df_all_conversions_per_continents_and_year)[1:2] <- c("continents", "conversions")
        names(df_all_conversions_per_continents_and_year)[3:(dim(TS_array_time_period)[1] + 2)] <- seq(years_start_end[1],years_start_end[2], by=1) 
        #names(df_all_conversions_per_continents_and_year)[3:(dim(TS_array_time_period)[1] + 2)] <- seq(years_start_end[2] - 65,years_start_end[2], by=1) 
        
        df_all_conversions_per_continents_and_year$continents <- rep(c("North America", "Caribbean and Mesoamerica", "South America", "Central and Western Europe", "North Africa and Western Asia", "West, Central, East and South Africa", "Eastern Europe", "Central Asia, North-East and South Asia", "South East Asia", "Oceania"), 3)
        
        df_all_conversions_per_continents_and_year$conversions <- rep(c("DEF", "G2C", "CRO_R2I"),10)
        #rep(c("CROr2CROi", "DBF2CRO" ,  "DBF2GRA" ,  "DNF2CRO" ,  "DNF2GRA" ,  "EBF2CRO" ,  "EBF2GRA",   "ENF2CRO" ,  "ENF2GRA" ,  "GRA2CRO"), 7)
        
        region_names <- c("North America", "Caribbean and Mesoamerica", "South America", "Central and Western Europe", "North Africa and Western Asia", "West, Central, East and South Africa", "Eastern Europe", "Central Asia, North-East and South Asia", "South East Asia", "Oceania")
        region_numbers <- c(1,2,3,4,5,6,7,8,9,10)
        conversions = c("CROr2CROi", "DBF2CRO" ,  "DBF2GRA" ,  "DNF2CRO" ,  "DNF2GRA" ,  "EBF2CRO" ,  "EBF2GRA",   "ENF2CRO" ,  "ENF2GRA" ,  "GRA2CRO")
        
        
        df_all_conversions_per_continents_and_year_sd <- data.frame(matrix(rep(NA, 10 * 3 * (dim(TS_array_time_period)[1] + 2)), ncol=dim(TS_array_time_period)[1] + 2))
        names(df_all_conversions_per_continents_and_year_sd)[1:2] <- c("continents", "conversions")
        names(df_all_conversions_per_continents_and_year_sd)[3:(dim(TS_array_time_period)[1] + 2)] <- seq(years_start_end[1],years_start_end[2], by=1) 
        #names(df_all_conversions_per_continents_and_year_sd)[3:(dim(TS_array_time_period)[1] + 2)] <- seq(years_start_end[2]-65,years_start_end[2], by=1) 
        df_all_conversions_per_continents_and_year_sd$continents <- rep(c("North America", "Caribbean and Mesoamerica", "South America", "Central and Western Europe", "North Africa and Western Asia", "West, Central, East and South Africa", "Eastern Europe", "Central Asia, North-East and South Asia", "South East Asia", "Oceania"), 3)
        df_all_conversions_per_continents_and_year_sd$conversions <- rep(c("DEF", "G2C", "CRO_R2I"),10)
        
        conversions_only_3 <- c("DEF", "G2C", "CRO_R2I")
        conversions_original_to_3 <- list(c("DBF2CRO" ,  "DBF2GRA" ,"DNF2CRO", "DNF2GRA", "EBF2CRO" ,"EBF2GRA",  "ENF2CRO", "ENF2GRA"), c("GRA2CRO"),c("CROr2CROi"))
        
        
        stderr <- function(x, na.rm=TRUE) {
          if (na.rm) x <- na.omit(x)
          sqrt(var(x)/length(x))
        }
        
        
        
        for(y in 1:length(seq(years_start_end[1],years_start_end[2], by=1)))
        #for(y in 1:length(seq(years_start_end[2]-65,years_start_end[2], by=1)))  
        #for(y in 1164:1165)  
        {
          
          print(y)
          for(i in 1:length(conversions_only_3))
          {
            print(i)
            
            for(j in 1:length(region_numbers))
            {
              #j=9 South East Asia
              print(j)
              #?rowSums
              #df_all_conversions_and_scenarios[i, "B17_DJF_high"] <- mean(rowSums((TS_array_time_period[,,, which(ncvar_get(ncin, "conversion") == paste(conversions[i]))], na.rm=T, dim=2) ,na.rm=T)
              #colSums(TS_array_time_period[,,, which(ncvar_get(ncin, "conversion") == paste(conversions[i]))], na.rm=T, dims=1)
              if(i == 1)
              {
                r_conversion <- rowSums(TS_array_time_period[y,,, which(ncvar_get(ncin, "conversion") %in% conversions_original_to_3[[i]])], na.rm=T, dims=2)
              } else {
                r_conversion <- TS_array_time_period[y,,, which(ncvar_get(ncin, "conversion") %in% conversions_original_to_3[[i]])]
              }
              r_conversion <- raster(t(matrix(r_conversion, nrow=1440)), xmn=-180, xmx=180, ymn=-90, ymx=90)
              crs(r_conversion) <- CRS("+init=epsg:4326")
              #plot(r_conversion)
              
              r_conversion_continent <- r_conversion
              r_conversion_continent[is.na(IPBES_sub_copy)] <- NA
              r_conversion_continent[IPBES_sub_copy != region_numbers[j]] <- NA
              #plot(r_conversion_continent)
              
              
              
              
              # if(i!=3)
              # {
              #   mask = mask_all_but_irri   
              # } else {
              #   mask = mask_only_irri
              # }
              #plot(mask_only_irri)
              #plot(mask_all_but_irri)
              
              mask = mask_all_but_irri
              
              r_conversion_continent[mask < luc_masks_percentages[k] & mask > -luc_masks_percentages[k]] <- NA
              r_conversion_continent[is.na(mask)] <- NA
              
              #plot(r_conversion_continent)
              
              
              
              df_all_conversions_per_continents_and_year[which(df_all_conversions_per_continents_and_year$continents == region_names[j] & df_all_conversions_per_continents_and_year$conversions ==  conversions_only_3[i] ), y+ 2] <- mean(getValues(r_conversion_continent), na.rm=T)
              
              df_all_conversions_per_continents_and_year_sd[which(df_all_conversions_per_continents_and_year$continents == region_names[j] & df_all_conversions_per_continents_and_year$conversions ==  conversions_only_3[i] ), y+ 2] <- stderr(getValues(r_conversion_continent), na.rm=T)
              
              
              #df_all_conversions_per_continents_and_year[df_all_conversions_per_continents_and_year$continents == "South East Asia" & df_all_conversions_per_continents_and_year$conversions == "CRO_R2I",]
              
              
            }
            
          }
        }
        
        write.table(df_all_conversions_per_continents_and_year, paste(output_dir, "temporal_mean_IPBES_regions_", season , "_", data_provider ,"_", scenario,"_",luc_masks_percentages[k],  "_new_irrigation_new.csv", sep=""))
        write.table(df_all_conversions_per_continents_and_year_sd, paste(output_dir, "temporal_sd_IPBES_regions_", season , "_", data_provider ,"_", scenario,"_",luc_masks_percentages[k], "_new_irrigation_new.csv", sep=""))
        
      }
    }
  }
}



