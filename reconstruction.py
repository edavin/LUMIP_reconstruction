#!/usr/bin/env python3
"""
Created 2020

@author: EL Davin
"""

import scipy
import xarray as xr
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns  # pandas aware plotting library
#import salem
import regionmask
from shapely.geometry import Polygon
from shapely.geometry import MultiPolygon
from shapely.geometry import shape
from osgeo import ogr
import geopandas as gpd
import fiona
from descartes.patch import PolygonPatch
import time
import matplotlib.image as mpimg
import matplotlib.pyplot as plt

##########################################################
# User settings
##########################################################
#years_start_end = [1900, 2017]
season = "DJF" #"JJA" or "DJF"
scen = "low"
blue_dir = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/"
blue_ver = "gracorr" #addc2p  new
irri_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
TS_dir = "/net/ch4/landclim/edavin/LUMIP/TS_data/"
out_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
#############################################################

#load BLUE data files

file_luc_DBF2CRO = blue_dir+"DBF2CRO_time_"+scen+"_"+blue_ver+".nc"
file_luc_DNF2CRO = blue_dir+"DNF2CRO_time_"+scen+"_"+blue_ver+".nc"
file_luc_EBF2CRO = blue_dir+"EBF2CRO_time_"+scen+"_"+blue_ver+".nc"
file_luc_ENF2CRO = blue_dir+"ENF2CRO_time_"+scen+"_"+blue_ver+".nc"
file_luc_DBF2GRA = blue_dir+"DBF2GRA_time_"+scen+"_"+blue_ver+".nc"
file_luc_DNF2GRA = blue_dir+"DNF2GRA_time_"+scen+"_"+blue_ver+".nc"
file_luc_EBF2GRA = blue_dir+"EBF2GRA_time_"+scen+"_"+blue_ver+".nc"
file_luc_ENF2GRA = blue_dir+"ENF2GRA_time_"+scen+"_"+blue_ver+".nc"
file_luc_GRA2CRO = blue_dir+"GRA2CRO_time_"+scen+"_"+blue_ver+".nc"
file_luc_CROr2CROi = irri_dir+"CROr2CROi_time_"+scen+".nc"

#open and concatenate LUC (BLUE/LUH2) data  
#this option will reorder datasets alphabeticaly
#DS_luc_reg = xr.open_mfdataset([dataDIR_luc_DBF2CRO_reg,dataDIR_luc_DNF2CRO_reg,dataDIR_luc_EBF2CRO_reg,dataDIR_luc_ENF2CRO_reg,dataDIR_luc_DBF2GRA_reg,dataDIR_luc_DNF2GRA_reg,dataDIR_luc_EBF2GRA_reg,dataDIR_luc_ENF2GRA_reg,dataDIR_luc_GRA2CRO_reg,dataDIR_luc_CROr2CROi_reg],concat_dim='conversion',combine='by_coords').to_array(dim='conversion')

#this option will keep the order of datasets
DS_luc = xr.open_mfdataset([file_luc_DBF2CRO,file_luc_DNF2CRO,file_luc_EBF2CRO,file_luc_ENF2CRO,file_luc_DBF2GRA,file_luc_DNF2GRA,file_luc_EBF2GRA,file_luc_ENF2GRA,file_luc_GRA2CRO,file_luc_CROr2CROi],concat_dim=None,combine='nested').to_array(dim='conversion')

#############################################################
#extract TS data
#############################################################

#B17 and D18 data
dataDIR_B17 = TS_dir+"TS_B17_0.25nn.nc"

dataDIR_D18_day = TS_dir+"LSTday_IGBPdet_gf_0.25nn.nc"
dataDIR_D18_night = TS_dir+"LSTnight_IGBPdet_gf_0.25nn.nc"

#open TS data
DS_B17_tmp = xr.open_dataset(dataDIR_B17)

DS_D18_day = xr.open_dataset(dataDIR_D18_day).Delta_LSTday_gapfilled
DS_D18_night = xr.open_dataset(dataDIR_D18_night).Delta_LSTnight_gapfilled

#conversions/transitions Duveillier
#;;Vegetation transition codes
#;;IGBPdet
#;;Duveiller        LUH2
#;;12  EBF->DBF
#;;13  EBF->ENF
#;;14  EBF->DNF
#;;15  EBF->MF
#;;16  EBF->SAV
#;;17  EBF->SHR
#;;18  EBF->GRA
#;;19  EBF->CRO
#;;110 EBF->WET
#;;23  DBF->ENF
#;;24  DBF->DNF
#;;25  DBF->MF
#;;26  DBF->SAV
#;;27  DBF->SHR
#;;28  DBF->GRA
#;;29  DBF->CRO
#;;210 DBF->WET
#;;34  ENF->DNF
#;;35  ENF->MF
#;;36  ENF->SAV
#;;37  ENF->SHR
#;;38  ENF->GRA
#;;39  ENF->CRO
#;;310 ENF->WET
#;;45  DNF->MF
#;;46  DNF->SAV
#;;47  DNF->SHR
#;;48  DNF->GRA
#;;49  DNF->CRO
#;;410 DNF->WET
#;;56  MF->SAV
#;;57  MF->SHR
#;;58  MF->GRA
#;;59  MF->CRO
#;;510 MF->WET
#;;67  SAV->SHR
#;;68  SAV->GRA
#;;69  SAV->CRO
#;;610 SAV->WET
#;;78  SHR->GRA
#;;79  SHR->CRO
#;;710 SHR->WET
#;;89  GRA->CRO
#;;810 GRA->WET
#;;910 CRO->WET



#conversions/transitions Bright
#;0(1) = CRO2ENF 
#;1(2) = CRO2DBF
#;2(3) = CRO2EBF
#;3(4) = GRA2ENF
#;4(5) = GRA2DBF
#;5(6) = GRA2EBF
#;6(7) = DBF2ENF 
#;7(8) = GRA2CRO
#;8(9) = CROr2CROi

dict_conversion_D18 = {   'DBF2CRO' : 29,
                          'DNF2CRO' : 49,
                          'EBF2CRO' : 19,
                          'ENF2CRO' : 39,
                          'DBF2GRA' : 28,
                          'DNF2GRA' : 48,
                          'EBF2GRA' : 18,
                          'ENF2GRA' : 38,
                          'GRA2CRO' : 89,
                          'CROr2CROi' : 12   #dummy(non-existing conversion)
                         }

dict_conversion_B17 = {   'DBF2CRO' : 1,
                          'DNF2CRO' : 0,  #dummy(non-existing conversion)
                          'EBF2CRO' : 2,
                          'ENF2CRO' : 0,
                          'DBF2GRA' : 4,
                          'DNF2GRA' : 0,  #dummy(non-existing conversion)
                          'EBF2GRA' : 5,
                          'ENF2GRA' : 3,
                          'GRA2CRO' : 7,
                          'CROr2CROi' : 8  
                         }


ind_D18 = [dict_conversion_D18[key] for key in DS_luc.conversion.values]
ind_B17 = [dict_conversion_B17[key] for key in DS_luc.conversion.values]

print(DS_luc.conversion.values)
print(ind_D18)
print(ind_B17)


#extract D18 and B17 data----------------------------------------

#first mean of day and night for D18
#DS_D18_tmp = (DS_D18.Delta_LSTday.sel(iTr = ind_D18) + DS_D18.Delta_LSTnight.sel(iTr = ind_D18))/2.
DS_D18_tmp = (DS_D18_day.sel(iTr = ind_D18) + DS_D18_night.sel(iTr = ind_D18))/2.

#then extract right season
if (season == "DJF"):
    DS_D18 = DS_D18_tmp.sel(time=[12.5,1.5,2.5]).mean(dim=["time"])
    DS_B17 = DS_B17_tmp.dTs_DJF.isel(conv = ind_B17)

elif (season == "MAM"):
    DS_D18 = DS_D18_tmp.sel(time=[3.5,4.5,5.5]).mean(dim=["time"])
    DS_B17 = DS_B17_tmp.dTs_MAM.isel(conv = ind_B17)

elif (season == "JJA"):
    DS_D18 = DS_D18_tmp.sel(time=[6.5,7.5,8.5]).mean(dim=["time"])
    DS_B17 = DS_B17_tmp.dTs_JJA.isel(conv = ind_B17)

elif (season == "SON"):
    DS_D18 = DS_D18_tmp.sel(time=[9.5,10.5,11.5]).mean(dim=["time"])
    DS_B17 = DS_B17_tmp.dTs_SON.isel(conv = ind_B17)

elif (season == "ANN"):
    DS_D18 = DS_D18_tmp.mean(dim=["time"])
    DS_B17 = (DS_B17_tmp.dTs_DJF.isel(conv = ind_B17) + DS_B17_tmp.dTs_MAM.isel(conv = ind_B17) + DS_B17_tmp.dTs_JJA.isel(conv = ind_B17) + DS_B17_tmp.dTs_SON.isel(conv = ind_B17)) /4.
    
else:
    print("error, season not found")
    

#assign common "conversion" axis to all datasets
DS_D18 = DS_D18.rename({'iTr' : 'conversion'})
DS_B17 = DS_B17.rename({'conv' : 'conversion'})

DS_D18 = DS_D18.assign_coords(conversion=DS_luc.conversion)
DS_B17 = DS_B17.assign_coords(conversion=DS_luc.conversion)


# change sign for all forest conversions in B17 as they are originaly from GRA/CRO to forest
DS_B17[0:7,:,:] = -DS_B17[0:7,:,:]

#conversions not existing in B17 are taken from D18 and vice-versa
ind = np.where(DS_luc.conversion == "DNF2CRO")[0]
print("DNF2CRO ind:",ind)
DS_B17[ind,:,:] = DS_D18[ind,:,:] #DNF2CRO from D18
ind = np.where(DS_luc.conversion == "DNF2GRA")[0]
print("DNF2GRA ind:",ind)
DS_B17[ind,:,:] = DS_D18[ind,:,:] #DNF2GRA from D18
ind = np.where(DS_luc.conversion == "CROr2CROi")[0]
print("CROr2CROi ind:",ind)
DS_D18[ind,:,:] = DS_B17[ind,:,:] #CROr2CROi from B17


# multiply LUC and LST sensitivity to get actual LUC effect on LST
TSrec_B17 = DS_B17 * DS_luc
TSrec_D18 = DS_D18 * DS_luc

# derive a map showing where B17 or D18 have no values while a conversion exists
DS_luc_sum = DS_luc.sum(dim=["time"])
#B17_missing = DS_B17_day.notnull().where(DS_luc_sum != 0.)
#D18_missing = DS_D18_day.notnull().where(DS_luc_sum != 0.)
B17_missing = DS_luc_sum.where(DS_B17.isnull())
D18_missing = DS_luc_sum.where(DS_D18.isnull())

#write full transient data to netcdf

path_file = out_dir+"TSrec_"+scen+"_B17_"+season+".nc"
print(path_file)
#TSrec_B17.to_dataset(name='TSrec').to_netcdf(path=path_file, unlimited_dims={'time':True},format='NETCDF4')
TSrec_B17.to_dataset(name='TSrec').to_netcdf(path=path_file, unlimited_dims={'time':True})

path_file = out_dir+"TSrec_"+scen+"_D18_"+season+".nc"
print(path_file)
TSrec_D18.to_dataset(name='TSrec').to_netcdf(path=path_file, unlimited_dims={'time':True})

#write integrated effect to netcdf

landmask = DS_luc[0,0,:,:].isnull()   #will result in 0 for land 1 for ocean

path_file = out_dir+"TSrec_"+scen+"_B17_"+season+"_850-2015sum.nc"
print(path_file)
TSrec_B17_sum = TSrec_B17.sum(dim=["time"])
TSrec_B17_sum = TSrec_B17_sum.where(~landmask)
TSrec_B17_sum.to_dataset(name='TSrec').to_netcdf(path=path_file,mode='w')
B17_missing.to_dataset(name='B17_missing').to_netcdf(path=path_file,mode='a')

path_file = out_dir+"TSrec_"+scen+"_D18_"+season+"_850-2015sum.nc"
print(path_file)
TSrec_D18_sum = TSrec_D18.sum(dim=["time"])
TSrec_D18_sum = TSrec_D18_sum.where(~landmask)
TSrec_D18_sum.to_dataset(name='TSrec').to_netcdf(path=path_file,mode='w')
D18_missing.to_dataset(name='D18_missing').to_netcdf(path=path_file,mode='a')

