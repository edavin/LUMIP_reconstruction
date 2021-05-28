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
year_start = 850
year_end = 2014
seasons = ["DJF","JJA"]
#seasons = ["JJA"]
scenarios = ["reg","high","low"]
#scenarios = ["low"]
in_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
out_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
#############################################################

#loop over scenarios
for scen in scenarios:
    #loop over seasons
    for season in seasons:
   
        #load reconstructions
        file_B17 = in_dir+"TSrec_"+scen+"_B17_"+season+"_850-2014.nc"
        TSrec_B17_full = xr.open_dataset(file_B17).TSrec
        file_D18 = in_dir+"TSrec_"+scen+"_D18_"+season+"_850-2014.nc"
        TSrec_D18_full = xr.open_dataset(file_D18).TSrec

        #subsample needed time slice
        TSrec_B17 = TSrec_B17_full.sel(time=slice(year_start,year_end))
        TSrec_D18 = TSrec_D18_full.sel(time=slice(year_start,year_end))

        #compute sum over time and write to netcdf

        #landmask = DS_luc[0,0,:,:].isnull()   #will result in 0 for land 1 for ocean

        path_file = out_dir+"TSrec_"+scen+"_B17_"+season+"_"+str(year_start)+"-"+str(year_end)+"sum.nc"
        print(path_file)
        TSrec_B17_sum = TSrec_B17.sum(dim=["time"])
        #TSrec_B17_sum = TSrec_B17_sum.where(~landmask)
        TSrec_B17_sum.to_dataset(name='TSrec').to_netcdf(path=path_file,mode='w')
        #B17_missing.to_dataset(name='B17_missing').to_netcdf(path=path_file,mode='a')

        path_file = out_dir+"TSrec_"+scen+"_D18_"+season+"_"+str(year_start)+"-"+str(year_end)+"sum.nc"
        print(path_file)
        TSrec_D18_sum = TSrec_D18.sum(dim=["time"])
        #TSrec_D18_sum = TSrec_D18_sum.where(~landmask)
        TSrec_D18_sum.to_dataset(name='TSrec').to_netcdf(path=path_file,mode='w')
        #D18_missing.to_dataset(name='D18_missing').to_netcdf(path=path_file,mode='a')

