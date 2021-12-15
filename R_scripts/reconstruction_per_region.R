##############################################################
#plot global map together with barplots for historical reconstruction
##############################################################

library(raster)
library(sp)
library(maptools)
library(rgdal)
library(ncdf4)
library(lattice)
library(ggplot2)
#library(ggmap)
#library(ggsubplot)
library(mapproj)
library(ggvis)
library(plyr)
library(rworldmap)
library(sp)
library(methods)
library(TeachingDemos)
require(RgoogleMaps)
library(grid)
library(dplyr)
library(rgeos)
library(plotrix)
#library(rmapshaper)
library(cowplot)
library(ggpubr)
library(ncmeta)
library(sf)
library(stars)
#----------------------------------------

# reconstruction ---------------
# season = "JJA" #"JJA" or "DJF" or "ANN"
# data_provider = "D18" #B17, D18
# scenario = "high"


all_seasons = c("JJA", "DJF") #, "ANN"
all_data_providers = c("D18", "B17")
all_scenarios = c("low", "high") #, *reg"



for(season in all_seasons)
{
  print(season)
  for(data_provider in all_data_providers)
  {
    print(data_provider)
    for(scenario in all_scenarios)
    {
      print(scenario)
      
      
      list.files("/net/ch4/landclim/edavin/LUMIP/python/")
      stack_resocnstruction <- stack(paste("/net/ch4/landclim/edavin/LUMIP/python/", "TSrec_", scenario,"_", data_provider,"_", season, "_850-2015sum.nc", sep=""))
      plot(stack_resocnstruction)
      spplot(stack_resocnstruction)
      
      # sum_all_reconstruction_D18 <-  sum(stack_resocnstruction[[c("CROr2CROi", "DBF2CRO", "DBF2GRA", "DNF2CRO", "DNF2GRA", "EBF2CRO", "EBF2GRA", "ENF2CRO", "ENF2GRA", "GRA2CRO")]])
      # plot(sum_all_reconstruction_D18)
      # 
      # sum_all_reconstruction_B17 <-  sum(stack_resocnstruction[[c("CROr2CROi", "DBF2CRO", "DBF2GRA", "DNF2CRO", "DNF2GRA", "EBF2CRO", "EBF2GRA", "ENF2CRO", "ENF2GRA", "GRA2CRO")]])
      # plot(sum_all_reconstruction_B17)
      # 
      # sum_all_reconstruction_mean_B17_D18 <- mean(sum_all_reconstruction_D18, sum_all_reconstruction_B17)
      # plot(sum_all_reconstruction_mean_B17_D18)
      
      #writeRaster(sum_all_reconstruction_mean_B17_D18, "/home/schwabj/scripts/figures/plots_for_edouard/sum_all_reconstruction_mean_B17_D18.tif")
      
      ########################
      #read luc rasters
      all_variables <- c("CROr2CROi", "DBF2CRO", "DBF2GRA", "DNF2CRO", "DNF2GRA", "EBF2CRO", "EBF2GRA", "ENF2CRO", "ENF2GRA", "GRA2CRO")
      all_rasters <- list.files("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized/", full.names = T)  

      
      all_luc_rasters <- raster::stack(c("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//CROr2CROi.tif", "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//DBF2CRO.tif" ,  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//DBF2GRA.tif" , "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//DNF2CRO.tif", "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//DNF2GRA.tif",  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//EBF2CRO.tif",  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//EBF2GRA.tif",  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//ENF2CRO.tif" , "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//ENF2GRA.tif" ,  "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized//GRA2CRO.tif" ))
      
      names(all_luc_rasters) <- all_variables
      plot(all_luc_rasters)
      spplot(all_luc_rasters, main="luc sum")
      mask_all_but_irri <- sum(all_luc_rasters[[c("DBF2CRO" ,  "DBF2GRA" ,  "DNF2CRO" ,  "DNF2GRA" ,  "EBF2CRO" ,  "EBF2GRA",   "ENF2CRO" ,  "ENF2GRA","GRA2CRO")]]) 
      spplot(mask_all_but_irri)
      
      mask_all_but_irri_05 <-  mask_all_but_irri
      mask_all_but_irri_05[mask_all_but_irri < 0.5 & mask_all_but_irri > -0.5] <- 0
      #mask_all_but_irri_05[mask_all_but_irri >= 1] <- 1
      #plot(mask_all_but_irri_05)
      mask_all_but_irri_05[mask_all_but_irri_05 > 0] <- 1
      plot(mask_all_but_irri_05, col=c("grey","red"), breaks=c(0,0.5,1) , colNA="blue", ylim=c(-90,90))
      #spplot(mask_all_but_irri_05)
      
      png("/home/schwabj/scripts/figures/plots_for_edouard/new_reconstruction_plots_2020_03/mask_05_plot_for_supplementary_material.png")
      plot(mask_all_but_irri_05, col=c("grey","red"), breaks=c(0,0.5,1) , colNA="blue", ylim=c(-90,90))
      dev.off()
      
      
      
      #combine regions and regions ########################################
      r_tmp <- stack_resocnstruction[[1]]
      r_tmp <- raster(t(matrix(r_tmp, nrow=1440)), xmn=-180, xmx=180, ymn=-90, ymx=90)
      crs(r_tmp) <- CRS("+init=epsg:4326")
      plot(r_tmp)
      
      # cont <- readShapeSpatial("/home/schwabj/scripts/r_scripts/plots_and_figures/region/region.shp")
      # plot(cont, col=c("white","black","grey50","red","blue","orange","green","yellow")) 
      # cont_raster <- rasterize(cont, r_tmp)
      # regions <- readShapeSpatial("/home/schwabj/scripts/r_scripts/plots_and_figures/region/region.shp")
      # plot(regions)
      # region_raster <- rasterize(regions, r_tmp) #takes quite long, about 30 seconds
      # plot(region_raster)
      # IPBES_sub_copy_merged <- cont_raster
      # IPBES_sub_copy_merged[region_raster == 19] <- 9
      # IPBES_sub_copy_merged[region_raster == 11] <- 9
      # plot(IPBES_sub_copy_merged)
      # region_names <- c("north_america", "south_america", "europe", "asia", "australia", "africa", "southeast_asia")
      # region_numbers <- c(4, 6, 8, 2, 3, 1, 9)
      
      
      
      IPBES_sub <- raster("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/IPBES_raster_summarized_regions.tif")
      plot(IPBES_sub)
      
      all_regions_land <- c(20, 21, 22, 23,24,25,26,27,28,29,30,31,32,33,34,35,36)
      all_regions_land_names <- c("Central Africa", "East Africa and adjacent islands", "North Africa", "Southern Africa", "West Africa", "Caribbean",  "Mesoamerica",   "North America", "South America", "North-East Asia", "Oceania",  "South-East Asia", "South Asia", "Western Asia","Central and Western Europe",  "Central Asia" , "Eastern Europe")
      
      IPBES_sub_copy <- IPBES_sub
      IPBES_sub_copy[!IPBES_sub %in% c(20, 21, 22, 23,24,25,26,27,28,29,30,31,32,33,34,35,36)] <- 0
      plot(IPBES_sub_copy)
      
      #merge regions ------------------------
      # "North America" c(27)
      # "Caribbean and Mesoamerica" c(25,26)
      # "South America" c(28)
      # "Central and Western Europe" c(34)
      # "North Africa and Western Asia" c(22, 33)
      # "West, Central, East and South Africa" c(20,21,23, 24)
      # "Eastern Europe" c(36)
      # "Central Asia, North-East and South Asia" c( 29,32, 35)
      # "South East Asia" c(31)
      # "Oceania" c(30)
      
      IPBES_sub_copy_merged <- IPBES_sub_copy
      IPBES_sub_copy_merged[IPBES_sub_copy %in% c(27)] <- 1 ; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(25,26)] <- 2 ; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(28)] <- 3 ; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(34)] <- 4; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(22, 33)] <- 5; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(20,21,23, 24)] <- 6 ;  IPBES_sub_copy_merged[IPBES_sub_copy %in% c(36)] <- 7 ;  IPBES_sub_copy_merged[IPBES_sub_copy %in% c(29,32, 35)] <- 8;   IPBES_sub_copy_merged[IPBES_sub_copy %in% c(31)] <- 9 ;   IPBES_sub_copy_merged[IPBES_sub_copy %in% c(30)] <- 10
      
      plot(IPBES_sub_copy_merged)
      str(IPBES_sub_copy_merged)
      
      
      
      #all_variables <- c("CROr2CROi", "DBF2CRO", "DBF2GRA", "DNF2CRO", "DNF2GRA", "EBF2CRO", "EBF2GRA", "ENF2CRO", "ENF2GRA", "GRA2CRO")
      spplot(stack_resocnstruction)
      
      
      
      DEF <- sum(stack_resocnstruction[[c("DBF2CRO" ,  "DBF2GRA" ,  "DNF2CRO" ,  "DNF2GRA" ,  "EBF2CRO" ,  "EBF2GRA",   "ENF2CRO" ,  "ENF2GRA")]])
      names(DEF) <- "DEF"
      plot(DEF, col = rev(heat.colors(10)))
      DEF_copy <- DEF
      DEF_copy[is.na(IPBES_sub_copy_merged)] <- NA
      plot(DEF_copy, col = rev(heat.colors(10)))
      
      
      CROr2CROi <- stack_resocnstruction[["CROr2CROi"]]
      plot(CROr2CROi, col = rev(heat.colors(10)))
      hist(getValues(CROr2CROi)[which(getValues(CROr2CROi) != 0)])
      GRA2CRO <- stack_resocnstruction[["GRA2CRO"]]
      plot(GRA2CRO, col = rev(heat.colors(10)))
      
      spplot(stack(DEF, CROr2CROi, GRA2CRO))
      spplot(stack(DEF, CROr2CROi, GRA2CRO), zlim=c(0,1))
      
      stack_summarized_conversions <- stack(DEF, CROr2CROi, GRA2CRO)
      
      #no individual masks
      mask_all_but_irri <- sum(all_luc_rasters[[c("DBF2CRO" ,  "DBF2GRA" ,  "DNF2CRO" ,  "DNF2GRA" ,  "EBF2CRO" ,  "EBF2GRA",   "ENF2CRO" ,  "ENF2GRA","GRA2CRO")]]) 
      spplot(mask_all_but_irri)
      
      
      
      luc_masks_percentages <- c(0,  0.5)
      
      list_with_data_frames <- list()
      
      conversions <- c("DEF","CROr2CROi", "GRA2CRO")
      
      
      
      
      for(k in 1:length(luc_masks_percentages))
      {
        print(paste("k:", k))
        print(luc_masks_percentages[k])
        
        # df_all_conversions_and_regions <- data.frame(matrix(rep(NA, 7 * 4), ncol=4))
        # names(df_all_conversions_and_regions) <- c("regions", "DEF","CROr2CROi", "GRA2CRO")
        # region_names <- c("north_america", "south_america", "europe", "asia", "australia", "africa", "southeast_asia")
        
        region_names <- c("North America", "Caribbean and Mesoamerica", "South America", "Central and Western Europe", "North Africa and Western Asia", "West, Central, East and South Africa", "Eastern Europe", "Central Asia, North-East and South Asia", "South East Asia", "Oceania")
        region_numbers <- c(1,2,3,4,5,6,7,8,9,10)
        
        df_all_conversions_and_regions <- data.frame(matrix(rep(NA, 10 * 4), ncol=4))
        names(df_all_conversions_and_regions) <- c("regions", "DEF","CROr2CROi", "GRA2CRO")
        
        
        
        df_all_conversions_and_regions$regions <- region_names
        
        
        for(i in 1:length(conversions))
        {
          print(i)
          
          for(j in 1:length(region_numbers))
          {
            print(j)
            #?rowSums
            #df_all_conversions_and_scenarios[i, "B17_DJF_high"] <- mean(rowSums((TS_array_time_period[,,, which(ncvar_get(ncin, "conversion") == paste(conversions[i]))], na.rm=T, dim=2) ,na.rm=T)
            r_conversion <- stack_summarized_conversions[[i]]
            #crs(r_conversion) <- CRS("+init=epsg:4326")
            #plot(r_conversion)
            
            r_conversion_region <- r_conversion
            r_conversion_region[is.na(IPBES_sub_copy_merged)] <- NA
            r_conversion_region[IPBES_sub_copy_merged != region_numbers[j]] <- NA
            plot(r_conversion_region)
            
            
            #individual masks
            # mask = all_luc_rasters[[paste(conversions[i])]]
            # plot(mask)
            # mask_region <- mask
            # mask_region[is.na(IPBES_sub_copy_merged)] <- NA
            # mask_region[IPBES_sub_copy_merged != region_numbers[j]] <- NA
            # plot(mask_region)
            
            #one mask for all
            mask = mask_all_but_irri
            plot(mask)
            mask_region <- mask
            mask_region[is.na(IPBES_sub_copy_merged)] <- NA
            mask_region[IPBES_sub_copy_merged != region_numbers[j]] <- NA
            plot(mask_region)
            
            r_conversion_region[mask_region < luc_masks_percentages[k] & mask_region > -luc_masks_percentages[k]] <- NA
            r_conversion_region[is.na(mask_region)] <- NA
            plot(r_conversion_region)
            #hist(r_conversion_region)
            #mean(getValues(r_conversion_region), na.rm=T)
            
            # mask_region_copy <- mask_region 
            # mask_region_copy[mask_region < luc_masks_percentages[k] & mask_region > -luc_masks_percentages[k]] <- NA
            # plot(mask_region_copy)
            # spplot(mask_region_copy)
            
            df_all_conversions_and_regions[j,i+1] <- mean(getValues(r_conversion_region), na.rm=T)
            
          }
          
        }
        
        
        
      }
      
      
      list_with_data_frames[[paste(luc_masks_percentages[k])]] <- df_all_conversions_and_regions
      saveRDS(list_with_data_frames, paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  season ,"_",  data_provider,"_" , scenario , "_mask_",luc_masks_percentages[k],   "_new_irrigation_new.rds", sep="") )
      
      
      
    }
  }
}
















