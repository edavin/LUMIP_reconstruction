library(raster)

dataDIR_luc_DBF2CRO = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/DBF2CRO_time_reg_gracorr.nc"
dataDIR_luc_DNF2CRO = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/DNF2CRO_time_reg_gracorr.nc"
dataDIR_luc_EBF2CRO = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/EBF2CRO_time_reg_gracorr.nc"
dataDIR_luc_ENF2CRO = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/ENF2CRO_time_reg_gracorr.nc"

dataDIR_luc_DBF2GRA = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/DBF2GRA_time_reg_gracorr.nc"
dataDIR_luc_DNF2GRA = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/DNF2GRA_time_reg_gracorr.nc"
dataDIR_luc_EBF2GRA = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/EBF2GRA_time_reg_gracorr.nc"
dataDIR_luc_ENF2GRA = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/ENF2GRA_time_reg_gracorr.nc"

dataDIR_luc_GRA2CRO = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/GRA2CRO_time_reg_gracorr.nc"
dataDIR_luc_CROr2CROi = "/net/ch4/landclim/edavin/LUMIP/python/CROr2CROi_time_high.nc"


all_files <- c(dataDIR_luc_CROr2CROi, dataDIR_luc_DBF2CRO, dataDIR_luc_DBF2GRA, dataDIR_luc_DNF2CRO, dataDIR_luc_DNF2GRA, dataDIR_luc_EBF2CRO, dataDIR_luc_EBF2GRA, dataDIR_luc_ENF2CRO, dataDIR_luc_ENF2GRA, dataDIR_luc_GRA2CRO)

all_variables <- c("CROr2CROi", "DBF2CRO", "DBF2GRA", "DNF2CRO", "DNF2GRA", "EBF2CRO", "EBF2GRA", "ENF2CRO", "ENF2GRA", "GRA2CRO")


for(i in 1:length(all_files))
{
  print(i)
  stack_conversion <- stack(all_files[i])
  sum_conversion <- sum(stack_conversion)
  writeRaster(sum_conversion, filename=paste("/net/ch4/landclim/schwabj/data/LUMIP_Jonas/luc_summarized/", all_variables[i] , ".tif", sep=""), format="GTiff")
}

