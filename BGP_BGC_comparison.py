#!/usr/bin/env python3
"""
Created 2020

@author: EL Davin
"""

import xarray as xr
import cartopy .crs as ccrsf
import mplotutils as mpu
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

##########################################################
# User settings
##########################################################

season = "JJA" #"JJA" or "DJF"
scen = "reg"

blue_file = '/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/180719__transitions_run_LUH_reg850-2014__CurrentCPools_CD_2014.nc'

file_B17 = "/net/ch4/landclim/edavin/LUMIP/python/TSrec_reg_B17_JJA_850-2015sum.nc"
file_D18 = "/net/ch4/landclim/edavin/LUMIP/python/TSrec_reg_D18_JJA_850-2015sum.nc"

tceq_B17 = "/net/cfc/landclim1/wimichae/ELD_Project/tCeq_LUH2_reg_B17_ANN_850-2017sum.nc"
tceq_D18 = "/net/cfc/landclim1/wimichae/ELD_Project/tCeq_LUH2_reg_D18_ANN_850-2017sum.nc"

TCRE_file = "/net/ch4/landclim/edavin/LUMIP/TCRE/monthlyMEAN_Ts_response_perGtC_1440x720.nc"
TCRE_STD_file = "/net/ch4/landclim/edavin/LUMIP/TCRE/monthlySTD_Ts_response_perGtC_1440x720.nc"

BGC_file = "/net/cfc/landclim1/wimichae/ELD_Project/GtC_to_Ts/annmean_Ts_response_to_367GtC_1440x720_regrid4.nc"

in_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
out_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
#############################################################

###########################################
# 1st option: BGC vs BGP comparison in Carbon equivalent
###########################################

#spatialy-explicit BGC flux from BLUE
#tc_blue = xr.open_dataset(blue_file).CD_A[0,:,:]

#CO2eq BGP effect 
#tceq_conv = (xr.open_dataset(tceq_B17).tCeq_ha_B17_reg + xr.open_dataset(tceq_D18).tCeq_ha_D18_reg) / 2.
#tceq = tceq_conv.sum(dim=["conversion"])

#BGP/BGC ratio (prevent division by 0)
#ratio = (tceq / tc_blue.where(tc_blue > 1)) * 100.

####################################
# 2nd option: Ts-based comparison
####################################

#Ts-equivalent of LUC BGC flux (i.e. 367 GtC since 850)
ts_map = xr.open_dataset(BGC_file).ts[0,:,:]

#plot map of Ts-equivalent of LUC BGC flux
data = ts_map
out_file = f'{out_dir}TCRE_367GtC_850-2017.pdf'

f, ax = plt.subplots(1, 1, subplot_kw=dict(projection=ccrs.Robinson()))

h = data.plot.pcolormesh(ax=ax, transform=ccrs.PlateCarree(),vmin=-2,vmax=2,cmap="RdBu_r", add_colorbar=False, rasterized=True)

ax.coastlines()
ax.set_global()
ax.set_title("")

f.subplots_adjust(left=0.025, right=0.875, bottom=0.05, top=0.95)
mpu.colorbar(h, ax, extend='both')
#mpu.colorbar(h, ax, extend='max')
plt.draw()
plt.savefig(out_file, dpi=400, bbox_inches="tight")

#calculate BGP/BGC ratio
file_B17 = f'{in_dir}TSrec_{scen}_B17_{season}_850-2015sum.nc'
file_D18 = f'{in_dir}TSrec_{scen}_D18_{season}_850-2015sum.nc'

rec = (xr.open_dataset(file_B17).TSrec + xr.open_dataset(file_D18).TSrec) / 2.
BGP = rec.sum(dim=["conversion"])

ratio = (BGP / ts_map.where(ts_map > 0.01)) * 100.

#plot map of BGP/BGC ratio
data = ratio
out_file = f'{out_dir}TS_BGPvsBGC_{scen}_{season}_850-2015.pdf'

f, ax = plt.subplots(1, 1, subplot_kw=dict(projection=ccrs.Robinson()))

h = data.plot.pcolormesh(ax=ax, transform=ccrs.PlateCarree(),vmin=-80,vmax=80,cmap="RdBu_r", add_colorbar=False, rasterized=True)

ax.coastlines()
ax.set_global()
ax.set_title("")

f.subplots_adjust(left=0.025, right=0.875, bottom=0.05, top=0.95)
mpu.colorbar(h, ax, extend='both')
#mpu.colorbar(h, ax, extend='max')
plt.draw()
plt.savefig(out_file, dpi=400, bbox_inches="tight")

##########################
# plot PDF of ratio
##########################
#set 0 as missing
#ratio = ratio.where(ratio != 0)
#ratio = ratio.where(ratio > 2 & ratio < 3)

#flatten array first to make it 1D
data = ratio.data.flatten()
#data = np.ndarray.flatten(ratio)

#plot histogram
plt.hist(data,
         range=[-20,20],
         bins=40,               # number of bins
         density=True,          # percentage instead of count
         histtype='stepfilled', # don't apply the edgecolor to the individual bars
         facecolor='indianred',
         edgecolor='0.1')

ratio.plot.pcolormesh(vmin=-20,vmax=20,cmap="RdBu_r",size=10)
