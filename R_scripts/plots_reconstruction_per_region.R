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

all_seasons = c("JJA", "DJF") #, "ANN"
all_data_providers = c("D18", "B17")
all_scenarios = c("low", "high") #, *reg"

out_dir_barplots <- "/net/ch4/landclim/schwabj/data/LUMIP_Jonas/barplots"


#################################################################################################
#barplots
#################################################################################################
#combine Duveillier and Bright annual mean 
#list_with_data_frames_D18 
#list_with_data_frames_B17 

###############
#DJF
###############

region_names <- c("Caribbean & Mesoamerica" ,    "Central & Western Europe"  ,     "Central, North-East & South Asia", "Eastern Europe" , "North Africa & Western Asia", "North America","Oceania"  , "South America", "South East Asia"  , "West, Central, East & South Africa"   )
region_numbers <- c(1,2,3,4,5,6,7,8,9,10)

list.files("/home/schwabj/scripts/figures/plots_for_edouard/")

list_with_data_frames_D18_DJF_low <- readRDS(paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  "DJF" ,"_",  "D18","_" , "low", "_mask_" , "0.5" , "_new_irrigation_new.rds", sep=""))
list_with_data_frames_D18_DJF_high <- readRDS(paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  "DJF" ,"_",  "D18","_" , "high", "_mask_" , "0.5" , "_new_irrigation_new.rds", sep=""))

list_with_data_frames_B17_DJF_low <- readRDS(paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  "DJF" ,"_",  "B17","_" , "low", "_mask_" , "0.5" , "_new_irrigation_new.rds", sep=""))
list_with_data_frames_B17_DJF_high <- readRDS(paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  "DJF" ,"_",  "B17","_" , "high", "_mask_" , "0.5" , "_new_irrigation_new.rds", sep=""))

#list_with_data_frames_D18_DJF_low <- readRDS(paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  "DJF" ,"_",  "D18","_" , "low", "_mask_" , "0.0" , ".rds", sep=""))

list_mean_data_frames_D18_B17_low_high <- list()
list_min_max_data_frames_D18_B17_low_high <- list()

luc_masks_percentages <- c(0,  0.5)




for(k in 2)#in c(1,2)) #1:length(luc_masks_percentages))
{
  # for(i in 1:length(df_all_conversions_and_regions$regions))
  # {
 
  #k=2
   
  new_df <- rbind(list_with_data_frames_D18_DJF_low[[paste(luc_masks_percentages[k])]], list_with_data_frames_D18_DJF_high[[paste(luc_masks_percentages[k])]], list_with_data_frames_B17_DJF_low[[paste(luc_masks_percentages[k])]], list_with_data_frames_B17_DJF_high[[paste(luc_masks_percentages[k])]]) 
  
 new_df$regions <- as.factor(new_df$regions)
 levels(new_df$regions) <- c("Caribbean & Mesoamerica" ,    "Central & Western Europe"  ,     "Central, North-East & South Asia", "Eastern Europe" , "North Africa & Western Asia", "North America","Oceania"  , "South America", "South East Asia"  , "West, Central, East & South Africa"   )
 
 
  
  new_df_mean <- aggregate(.~regions,FUN=mean, data=new_df)
  new_df_min <- aggregate(.~regions,FUN=min, data=new_df)
  new_df_max <- aggregate(.~regions,FUN=max, data=new_df)
  
  new_df_mean$total <- rowSums(new_df_mean[,2:4])
  new_df_min$total  <- rowSums(new_df_min[,2:4])
  new_df_max$total  <- rowSums(new_df_max[,2:4])
  
  names(new_df_min) <- paste("min_", names(new_df_min), sep="")
  names(new_df_max) <- paste("max_", names(new_df_max), sep="")
  
  new_df_mean_melted <- reshape2::melt(new_df_mean)
  new_df_min_melted <- reshape2::melt(new_df_min)
  new_df_max_melted <- reshape2::melt(new_df_max)
  
  new_df_mean_melted$min <- new_df_min_melted$value
  new_df_mean_melted$max <- new_df_max_melted$value
  
  if(k==1)
  {
    ymin = -0.1; ymax=0.3
  } else{
    ymin = -0.5; ymax=0.8
  }
    
  for(i in 1:length(region_names))
  {
    print(i)
    print(region_names[i])
    
    pp <- ggplot(new_df_mean_melted[new_df_mean_melted$regions == region_names[i],]) + geom_bar(aes(x=regions, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=regions, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5)) +  facet_wrap(~regions, nrow=1) +  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey")) + theme_bw(base_size=24)   + ylab(expression(Delta*"T[K]")) + ylim(ymin, ymax)  + theme(panel.grid.major.x = element_blank() ) + theme(legend.title = element_blank(), axis.title.x = element_blank(), axis.text.x= element_blank(), axis.ticks.x = element_blank(), strip.text = element_text(size = 18)) + xlab("") + theme(legend.position = "none") #+  facet_wrap(~regions, nrow=1,strip.position="right")
    
    print(pp)
    
    #ggsave(paste(out_dir_barplots, "/barplot_DJF_",  region_names[i] , "_", luc_masks_percentages[k] ,".png"),pp,  "png")
  }
  #write.table(x=new_df_mean_melted, file=out_dir_barplots, "/DJF.csv", sep=";")
}
  


last_in_group = new_df_mean_melted  %>%
  group_by( regions, variable) %>%
  summarize() %>%
  group_by(regions) %>%
  summarize(x = as.integer(tail(regions,1)) + .5 ) 

last_in_group = last_in_group[-10,]

ggplot(new_df_mean_melted) + geom_bar(aes(x=regions, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=regions, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5)) + theme_bw(base_size=20) + theme(axis.text.x = element_text(angle = 90, vjust = 0.4, hjust=1))+  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey"),labels=c("Deforestation", "Rainfed cropland to irrigated cropland", "Grassland to cropland", "Total"), guide = guide_legend(  direction = "horizontal",  title.position = "top", label.position = "top", label.hjust = 0, label.vjust = 0.5, label.theme = element_text(angle = 90))) + geom_vline(xintercept = last_in_group$x, lwd = 0.5, linetype=2, alpha = 0.5) + ylab(expression(Delta*"T[K]")) + xlab("") + theme(legend.title = element_blank()) 

ggplot(new_df_mean_melted) + geom_bar(aes(x=regions, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=regions, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5)) + theme_bw(base_size=20) + theme(axis.text.x = element_text(angle = 90, vjust = 0.4, hjust=1))+  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey"),labels=c("Deforestation", "Rainfed cropland to irrigated cropland", "Grassland to cropland", "Total")) + geom_vline(xintercept = last_in_group$x, lwd = 0.5, linetype=2, alpha = 0.4) + ylab(expression(Delta*"T[K]")) + xlab("") + theme(legend.title = element_blank())  + theme(legend.position = c(0.45, 0.85),legend.background = element_rect(fill="transparent"))

pp <- ggplot(new_df_mean_melted) + geom_bar(aes(x=regions, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=regions, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5)) + theme_bw(base_size=12) + theme(axis.text.x = element_text(angle = 90, vjust = 0.4, hjust=1))+  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey"),labels=c("Deforestation", "Rainfed cropland to irrigated cropland", "Grassland to cropland", "Total"),guide=guide_legend(nrow=2)) + geom_vline(xintercept = last_in_group$x, lwd = 0.5, linetype=2, alpha = 0.5) + ylab(expression(Delta*"T[K]")) + xlab("") + theme(legend.title = element_blank()) + theme(legend.position="top")

print(pp)

ggsave(paste(out_dir_barplots, "/barplot_DJF_all_regions", "_", luc_masks_percentages[k] ,".png", sep=""),pp,  "png")

new_df_mean_melted_four_regions <- new_df_mean_melted[new_df_mean_melted$regions %in% c("North America", "Central & Western Europe", "South America", "Central, North-East & South Asia"), ]

new_df_mean_melted_four_regions <- new_df_mean_melted[new_df_mean_melted$regions %in% c("North America", "Central & Western Europe", "South America", "Central, North-East & South Asia"), ]
last_in_group <- last_in_group[1:3,]

pp <- ggplot(new_df_mean_melted_four_regions) + geom_bar(aes(x=regions, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=regions, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5)) + theme_bw(base_size=12) + theme(axis.text.x = element_text(angle = 90, vjust = 0.4, hjust=1))+  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey"),labels=c("Deforestation", "Rainfed cropland to irrigated cropland", "Grassland to cropland", "Total"),guide=guide_legend(nrow=2)) + geom_vline(xintercept = last_in_group$x, lwd = 0.5, linetype=2, alpha = 0.5) + ylab(expression(Delta*"T[K]")) + xlab("") + theme(legend.title = element_blank()) + theme(legend.position="top")

print(pp)

ggsave(paste(out_dir_barplots, "/barplot_DJF_four_regions", "_", luc_masks_percentages[k] ,".png", sep=""),pp,  "png")


pp <- ggplot(new_df_mean_melted_four_regions) + geom_bar(aes(x=variable, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=variable, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5))  + theme_bw() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))  +  facet_wrap(~regions , nrow=1,strip.position="left") +  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey"),labels=c("Deforestation", "Rainfed cropland to irrigated cropland", "Grassland to cropland", "Total"),guide=guide_legend(nrow=2)) + theme_bw(base_size=12)  +   theme(axis.title.x=element_blank(),  axis.text.x=element_blank(),   axis.ticks.x=element_blank())   + theme(legend.title = element_blank()) + theme(legend.position="top") + scale_y_continuous(position = "right") +  theme(axis.title.y.right= element_text(angle = 90)) + ylab(expression(Delta*"T[K]"))

print(pp)

ggsave(paste(out_dir_barplots, "/barplot_DJF_four_regions_facets_", "_", luc_masks_percentages[k] ,".png", sep=""),pp,  "png", width=6, height=4)



###############
#JJA
###############

region_names <- c("Caribbean & Mesoamerica" ,    "Central & Western Europe"  ,     "Central, North-East & South Asia", "Eastern Europe" , "North Africa & Western Asia", "North America","Oceania"  , "South America", "South East Asia"  , "West, Central, East & South Africa"   )
region_numbers <- c(1,2,3,4,5,6,7,8,9,10)

list_with_data_frames_D18_JJA_low <- readRDS(paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  "JJA" ,"_",  "D18","_" , "low", "_mask_" , "0.5" , "_new_irrigation_new.rds", sep=""))
list_with_data_frames_D18_JJA_high <- readRDS(paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  "JJA" ,"_",  "D18","_" , "high", "_mask_" , "0.5" , "_new_irrigation_new.rds", sep=""))

list_with_data_frames_B17_JJA_low <- readRDS(paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  "JJA" ,"_",  "B17","_" , "low", "_mask_" , "0.5" , "_new_irrigation_new.rds", sep=""))
list_with_data_frames_B17_JJA_high <- readRDS(paste("/home/schwabj/scripts/figures/plots_for_edouard/new_regions_",  "JJA" ,"_",  "B17","_" , "high", "_mask_" , "0.5" , "_new_irrigation_new.rds", sep=""))


list_mean_data_frames_D18_B17_low_high <- list()
list_min_max_data_frames_D18_B17_low_high <- list()

luc_masks_percentages <- c(0,  0.5)

for(k in 2) #c(1,2)) #1:length(luc_masks_percentages))
{
  # for(i in 1:length(df_all_conversions_and_regions$regions))
  # {
  
  new_df <- rbind(list_with_data_frames_D18_JJA_low[[paste(luc_masks_percentages[k])]], list_with_data_frames_D18_JJA_high[[paste(luc_masks_percentages[k])]], list_with_data_frames_B17_JJA_low[[paste(luc_masks_percentages[k])]], list_with_data_frames_B17_JJA_high[[paste(luc_masks_percentages[k])]]) 
  
  new_df$regions <- as.factor(new_df$regions)
  levels(new_df$regions) <- c("Caribbean & Mesoamerica" ,    "Central & Western Europe"  ,     "Central, North-East & South Asia", "Eastern Europe" , "North Africa & Western Asia", "North America","Oceania"  , "South America", "South East Asia"  , "West, Central, East & South Africa"   )
  
  
  new_df_mean <- aggregate(.~regions,FUN=mean, data=new_df)
  new_df_min <- aggregate(.~regions,FUN=min, data=new_df)
  new_df_max <- aggregate(.~regions,FUN=max, data=new_df)
  
  new_df_mean$total <- rowSums(new_df_mean[,2:4])
  new_df_min$total  <- rowSums(new_df_min[,2:4])
  new_df_max$total  <- rowSums(new_df_max[,2:4])
  
  names(new_df_min) <- paste("min_", names(new_df_min), sep="")
  names(new_df_max) <- paste("max_", names(new_df_max), sep="")
  
  new_df_mean_melted <- reshape2::melt(new_df_mean)
  new_df_min_melted <- reshape2::melt(new_df_min)
  new_df_max_melted <- reshape2::melt(new_df_max)
  
  new_df_mean_melted$min <- new_df_min_melted$value
  new_df_mean_melted$max <- new_df_max_melted$value
  
  if(k==1)
  {
    ymin = -0.1; ymax=0.3
  } else{
    ymin = -0.5; ymax=0.8
  }
  
  for(i in 1:length(region_names))
  {
    print(i)
    print(region_names[i])
    
    pp <- ggplot(new_df_mean_melted[new_df_mean_melted$regions == region_names[i],]) + geom_bar(aes(x=regions, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=regions, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5)) +  facet_wrap(~regions, nrow=1) +  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey")) + theme_bw(base_size=24)   + ylab(expression(Delta*"T[K]")) + ylim(ymin, ymax)  + theme(panel.grid.major.x = element_blank() ) + theme(legend.title = element_blank(), axis.title.x = element_blank(), axis.text.x= element_blank(), axis.ticks.x = element_blank(), strip.text = element_text(size = 18)) + xlab("") + theme(legend.position = "none") #+  facet_wrap(~regions, nrow=1,strip.position="right")
    
    print(pp)
    
    #ggsave(paste(out_dir_barplots, "/barplot_JJA_",  region_names[i] , "_", luc_masks_percentages[k] ,".png"),pp,  "png")
    
  }
  
  #write.table(x=new_df_mean_melted, file=out_dir_barplots, "/JJA.csv", sep=";")
}

ggplot(new_df_mean_melted) + geom_bar(aes(x=regions, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=regions, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5)) +  facet_wrap(~regions, nrow=1,strip.position="right")



last_in_group = new_df_mean_melted  %>%
  group_by( regions, variable) %>%
  summarize() %>%
  group_by(regions) %>%
  summarize(x = as.integer(tail(regions,1)) + .5 ) 

last_in_group = last_in_group[-10,]

pp <- ggplot(new_df_mean_melted) + geom_bar(aes(x=regions, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=regions, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5)) + theme_bw(base_size=12) + theme(axis.text.x = element_text(angle = 90, vjust = 0.4, hjust=1))+  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey"),labels=c("Deforestation", "Rainfed cropland to irrigated cropland", "Grassland to cropland", "Total"),guide=guide_legend(nrow=2)) + geom_vline(xintercept = last_in_group$x, lwd = 0.5, linetype=2, alpha = 0.5) + ylab(expression(Delta*"T[K]")) + xlab("") + theme(legend.title = element_blank()) + theme(legend.position="top")

print(pp)

ggsave(paste(out_dir_barplots, "/barplot_JJA_all_regions", "_", luc_masks_percentages[k] ,".png", sep=""),pp,  "png")



new_df_mean_melted_four_regions <- new_df_mean_melted[new_df_mean_melted$regions %in% c("North America", "Central & Western Europe", "South America", "Central, North-East & South Asia"), ]
last_in_group <- last_in_group[1:3,]

pp <- ggplot(new_df_mean_melted_four_regions) + geom_bar(aes(x=regions, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=regions, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5)) + theme_bw(base_size=12) + theme(axis.text.x = element_text(angle = 90, vjust = 0.4, hjust=1))+  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey"),labels=c("Deforestation", "Rainfed cropland to irrigated cropland", "Grassland to cropland", "Total"),guide=guide_legend(nrow=2)) + geom_vline(xintercept = last_in_group$x, lwd = 0.5, linetype=2, alpha = 0.5) + ylab(expression(Delta*"T[K]")) + xlab("") + theme(legend.title = element_blank()) + theme(legend.position="top")

print(pp)

ggsave(paste(out_dir_barplots, "/barplot_JJA_four_regions", "_", luc_masks_percentages[k] ,".png", sep=""),pp,  "png")


pp <- ggplot(new_df_mean_melted_four_regions) + geom_bar(aes(x=variable, y=value, fill=variable),stat="identity",position="dodge")  + geom_errorbar(aes(x=variable, ymin = min, ymax = max), position = position_dodge2(width = 0.5, padding = 0.5))  + theme_bw() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))  +  facet_wrap(~regions , nrow=1,strip.position="left") +  scale_fill_manual(values=c( "saddlebrown", "blue", "dark green", "grey"),labels=c("Deforestation", "Rainfed cropland to irrigated cropland", "Grassland to cropland", "Total"),guide=guide_legend(nrow=2)) + theme_bw(base_size=12)  +   theme(axis.title.x=element_blank(),  axis.text.x=element_blank(),   axis.ticks.x=element_blank())   + theme(legend.title = element_blank()) + theme(legend.position="top") + scale_y_continuous(position = "right") +  theme(axis.title.y.right= element_text(angle = 90)) + ylab(expression(Delta*"T[K]"))

print(pp)

ggsave(paste(out_dir_barplots, "//barplot_JJA_four_regions_facets_", "_", luc_masks_percentages[k] ,".png", sep=""),pp,  "png" , width=6, height=4)








