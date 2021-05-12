#create IBES region mask
#script Jonas Schwaab
#----------------------------------------------------------------------------------

#load packages
library(sp)
library(maptools)
library(raster)
library(rgdal)
library(gdalUtils)
library(nngeo)
library(spatialEco)
library(smoothr)

#! gdalUtils can cause some troubles, the right R version should be selected, what usually works fine is loading the version: 
#module load R/4.0.3-openblas and afterwards module load rstudio



###########################################################################
#rasterize the shapefile (transform into grid that has the same extent/resolution as the netcdfs of the reconstruction)

#the original shapefile is downloaded from "https://datadryad.org/stash/dataset/doi:10.5061/dryad.6gb90", this link is provided in the paper Brooks et al. 2016: Analysing biodiversity and conservation knowledge products to support regional environmental assessments, the link is a bit hidden, it is in the online version of the document under "Data Citation 2"

#read the shapefile and have a look at it
#IPBES <- readOGR("/net/ch4/landclim/schwabj/data/IPBES_and_GEO_regions/doi_10.5061_dryad.6gb90__v2/EEZ_WVS_layer/EEZv8_WVS_DIS_V3_ALL_final_v7disIPBES/EEZv8_WVS_DIS_V3_ALL_final_v7disIPBES.shp") #takes approx 2 minutes because the data is very detailed
#plot(IPBES) #the plotting also takes quite a while

#look ath the IPBES_sub layer
#IPBES$IPBES_sub_2_NUM = as.numeric(IPBES$IPBES_sub)  # Make new attribute
#writeOGR(obj = IPBES, dsn = "/net/ch4/landclim/schwabj/data/tmp_edouard_lumip/", layer = "IPBES_numeric", driver = "ESRI Shapefile") # Save new version of shapefile

#load the reconstruction files so that a region mask can later on be created in a way that is consistent with "reconstruction grid"
list.files("/net/ch4/landclim/edavin/LUMIP/python/")
stack_resocnstruction <- stack(paste("/net/ch4/landclim/edavin/LUMIP/python/TSrec_reg_D18_JJA_850-2015sum.nc", sep=""))
#plot(stack_resocnstruction)

#select one of the reconstruction grids and define extent and projection
tmp_raster <- stack_resocnstruction[[1]]
#plot(tmp_raster)

system.time(writeRaster(tmp_raster, filename = paste("/net/ch4/landclim/schwabj/data/tmp_edouard_lumip/IPBES_raster.tif", sep=""), overwrite=TRUE)) #save the IPBES raster into which the IPBES shapefile information will be written into
system.time(a_test <- gdalUtils::gdal_rasterize(src_datasource="/net/ch4/landclim/schwabj/data/IPBES_and_GEO_regions/doi_10.5061_dryad.6gb90__v2/EEZ_WVS_layer/EEZv8_WVS_DIS_V3_ALL_final_v7disIPBES/EEZv8_WVS_DIS_V3_ALL_final_v7disIPBES.shp", dst_filename =  "/net/ch4/landclim/schwabj/data/tmp_edouard_lumip/IPBES_raster.tif", a = "OBJECTID", output_Raster=TRUE)) #write shapefile information into the raster/grid, takes 15-20 minutes on ch4

IPBES_sub <- raster("/net/ch4/landclim/schwabj/data/tmp_edouard_lumip/IPBES_raster.tif")
plot(IPBES_sub)

# IPBES <- readOGR("/net/ch4/landclim/schwabj/data/IPBES_and_GEO_regions/doi_10.5061_dryad.6gb90__v2/EEZ_WVS_layer/EEZv8_WVS_DIS_V3_ALL_final_v7disIPBES/EEZv8_WVS_DIS_V3_ALL_final_v7disIPBES.shp") #takes approx 2 minutes
# IPBES$IPBES_sub #check names of regions
# IPBES$OBJECTID #check ids

all_regions_land <- c(20, 21, 22, 23,24,25,26,27,28,29,30,31,32,33,34,35,36)
all_regions_land_names <- c("Central Africa", "East Africa and adjacent islands", "North Africa", "Southern Africa", "West Africa", "Caribbean",  "Mesoamerica",   "North America", "South America", "North-East Asia", "Oceania",  "South-East Asia", "South Asia", "Western Asia","Central and Western Europe",  "Central Asia" , "Eastern Europe")

IPBES_sub_copy <- IPBES_sub #modify regions based on a copy of the IPBES_sub data
IPBES_sub_copy[!IPBES_sub %in% c(20, 21, 22, 23,24,25,26,27,28,29,30,31,32,33,34,35,36)] <- 0 #all regions that are not land regions are set to zero
plot(IPBES_sub_copy)

#merge regions
# "North America" c(27), "Caribbean and Mesoamerica" c(25,26), "South America" c(28), "Central and Western Europe" c(34), "North Africa and Western Asia" c(22, 33), "West, Central, East and South Africa" c(20,21,23, 24), "Eastern Europe" c(36),  "Central Asia, North-East and South Asia" c( 29,32, 35),  "South East Asia" c(31),  "Oceania" c(30)

IPBES_sub_copy_merged <- IPBES_sub_copy #make a copy
IPBES_sub_copy_merged[IPBES_sub_copy %in% c(27)] <- 1 ; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(25,26)] <- 2 ; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(28)] <- 3 ; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(34)] <- 4; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(22, 33)] <- 5; IPBES_sub_copy_merged[IPBES_sub_copy %in% c(20,21,23, 24)] <- 6 ;  IPBES_sub_copy_merged[IPBES_sub_copy %in% c(36)] <- 7 ;  IPBES_sub_copy_merged[IPBES_sub_copy %in% c(29,32, 35)] <- 8;   IPBES_sub_copy_merged[IPBES_sub_copy %in% c(31)] <- 9 ;   IPBES_sub_copy_merged[IPBES_sub_copy %in% c(30)] <- 10
plot(IPBES_sub_copy_merged)

system.time(writeRaster(IPBES_sub_copy_merged, filename = paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/IPBES_raster_summarized_regions.tif", sep=""), overwrite=TRUE)) #save the IPBES raster into which the IPBES shapefile information will be written into

IPBES_sub_copy_merged <- raster("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/IPBES_raster_summarized_regions.tif")
plot(IPBES_sub_copy_merged)

#create new shapefile based on the newly defined regions
IPBES_sub_copy_merged_low_res  <- raster::aggregate(IPBES_sub_copy_merged, fact=2, fun="max") #lower the resolution a bit so that the shapefile is less complex
plot(IPBES_sub_copy_merged_low_res) 
system.time(new_shapefile <- rasterToPolygons(IPBES_sub_copy_merged_low_res, dissolve = T)) #takes approx 5 minutes for original resolution and approx 1 minutes for low res
plot(new_shapefile) #str(new_shapefile)
#IPBES_sub_copy_merged_low_res_clump <- clump(IPBES_sub_copy_merged_low_res)
area_thresh <- units::set_units(200000, km^2)
new_shapefile_smooth <- drop_crumbs(x=new_shapefile, threshold = area_thresh)
plot(new_shapefile_smooth)

writeOGR(obj = new_shapefile, dsn = "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/", layer = "IPBES_new_shapefile_from_grid", driver = "ESRI Shapefile")




new_shapefile <- readOGR("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/IPBES_new_shapefile_from_grid.shp")
plot(new_shapefile)

PROJ <- "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs" 
new_shapefile  <- spTransform(new_shapefile, CRSobj = PROJ)
plot(new_shapefile)

pdf("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/new_regions_robinson.pdf")
plot(new_shapefile)
dev.off()






###########################################################################
#work on the shapefile (i.e. work on the polygon data)


IPBES <- readOGR("/net/ch4/landclim/schwabj/data/IPBES_and_GEO_regions/doi_10.5061_dryad.6gb90__v2/EEZ_WVS_layer/EEZv8_WVS_DIS_V3_ALL_final_v7disIPBES/EEZv8_WVS_DIS_V3_ALL_final_v7disIPBES.shp") #takes approx 2 minutes
#IPBES_EA <- IPBES[IPBES$IPBES_sub == "Eastern Europe",]
#plot(IPBES_EA)

IPBES_land  <-  IPBES[IPBES$OBJECTID %in% c(20, 21, 22, 23,24,25,26,27,28,29,30,31,32,33,34,35,36),]
#plot(IPBES_land) #takes very long

area_thresh <- units::set_units(50000, km^2)
system.time(IPBES_land_smooth <- drop_crumbs(x=IPBES_land, threshold = area_thresh)) #takes approx. 1 minute
plot(IPBES_land_smooth)

IPBES_land_smooth@data

OBJECTID <-     c(27, 25, 26, 28, 34, 22, 33, 20, 21, 23, 24, 36, 29, 32, 35, 31, 30)
new_regions_ID <- c(1 , 2,  2,  3,  4,  5,  5,  6,  6,  6,  6,  7,  8,  8,  8,  9,  10)
new_regions_table <- cbind(OBJECTID, new_regions_ID)

IPBES_land_smooth@data <- merge(IPBES_land_smooth@data, new_regions_table, by = "OBJECTID")
plot(IPBES_land_smooth)


##https://www.r-bloggers.com/2015/09/dissolve-polygons-in-r/

#?gUnaryUnion
system.time(IPBES_land_smooth_regions <- gUnaryUnion(sp=IPBES_land_smooth,   id = IPBES_land_smooth@data$new_regions_ID)) #30-90 seconds
plot(IPBES_land_smooth_regions)
str(IPBES_land_smooth_regions)



IPBES_land_smooth_region_df <- as.data.frame(sapply(slot(IPBES_land_smooth_regions, "polygons"), function(x) slot(x, "ID")))

IPBES_land_smooth_region_df <- SpatialPolygonsDataFrame(IPBES_land_smooth_regions, IPBES_land_smooth_region_df)

names(IPBES_land_smooth_region_df) <- "ID"
IPBES_land_smooth_region_df$rgn_nms <- #c("North America", "Caribbean and Mesoamerica", "South America", "Central and Western Europe", "North Africa and Western Asia", "West, Central, East and South Africa", "Eastern Europe", "Central Asia, North-East and South Asia", "South East Asia", "Oceania")
#the column name needs to be short: rgn_nms instead of region_names, otherwise problems when saving the shapefile
  
  
plot(IPBES_land_smooth_region_df)
  
IPBES_land_smooth_region_df_simplified <- gSimplify(IPBES_land_smooth_regions, tol=0.1)
plot(IPBES_land_smooth_region_df_simplified)

IPBES_land_smooth_region_df_simplified = SpatialPolygonsDataFrame(IPBES_land_smooth_region_df_simplified, data=IPBES_land_smooth_region_df@data)
plot(IPBES_land_smooth_region_df_simplified)

IPBES_land_smooth_region_df_simplified@data

writeOGR(obj = IPBES_land_smooth_regions_simplified, dsn = "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/", layer = "IPBES_new_shapefile", driver = "ESRI Shapefile",overwrite_layer=T)

new_shapefile <- readOGR("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/IPBES_new_shapefile.shp") #takes approx 2 minutes
new_shapefile@data
plot(new_shapefile)

PROJ <- "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs" 
new_shapefile  <- spTransform(new_shapefile, CRSobj = PROJ)
plot(new_shapefile)

pdf("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/new_regions_robinson_based_on_vector_data.pdf")
plot(new_shapefile)
dev.off()

#c("North America", "Central & Western Europe", "South America", "Central, North-East & South Asia")

new_shapefile_four_regions <- new_shapefile[c(1,3,4,8) ,]
plot(new_shapefile_four_regions, border="grey", lwd=3)

pdf("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/region_mask/new_regions_robinson_based_on_vector_data_grey.pdf")
plot(new_shapefile_four_regions, border="grey", lwd=3)
dev.off()

