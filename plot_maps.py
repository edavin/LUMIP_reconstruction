#!/usr/bin/env python3
"""
Created 2020

@author: EL Davin
"""

import xarray as xr
import mplotutils as mpu
import matplotlib.pyplot as plt
import cartopy.crs as ccrs

##########################################################
# User settings
##########################################################

#season = "JJA" #"JJA" or "DJF"
#scen = "reg"

in_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
out_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
#############################################################


#for scen in ["reg","high","low"]:
for scen in ["reg"]:
    #for season in ["DJF","JJA","ANN"]:
    for season in ["JJA"]:
        for DS in ["D18","B17","combo"]:
            if DS == "D18" or DS == "B17":
                file_in = in_dir+"TSrec_"+scen+"_"+DS+"_"+season+"_850-2015sum.nc"
                print(file_in)
                rec = xr.open_dataset(file_in).TSrec
            elif DS == "combo":
                file_B17 = in_dir+"TSrec_"+scen+"_B17_"+season+"_850-2015sum.nc"
                file_D18 = in_dir+"TSrec_"+scen+"_D18_"+season+"_850-2015sum.nc"
                rec = (xr.open_dataset(file_B17).TSrec + xr.open_dataset(file_D18).TSrec) / 2.
            
            defo = rec.sel(conversion=['DBF2CRO', 'DBF2GRA', 'DNF2CRO', 'DNF2GRA', 'EBF2CRO', 'EBF2GRA', 'ENF2CRO', 'ENF2GRA',]).sum(dim=["conversion"])
            gra = rec.sel(conversion=['GRA2CRO'])[0,:,:]
            irr = rec.sel(conversion=['CROr2CROi'])[0,:,:]
            tot = rec.sum(dim=["conversion"])

            datadict = {
                'def' : defo,
                'gra' : gra, 
                'irr' : irr,
                'tot' : tot, 
            }
        
            for key in datadict:
                print(f"This is dataset {key}, {scen}, {DS}, {season} and it has the following shape: ")
                print(datadict[key].shape)
    
                data = datadict[key]
                file = f'{out_dir}TSrec_{key}_{scen}_{DS}_{season}_850-2015sum.pdf'

                f, ax = plt.subplots(1, 1, subplot_kw=dict(projection=ccrs.Robinson()))

                h = data.plot.pcolormesh(ax=ax, transform=ccrs.PlateCarree(),vmin=-0.6,vmax=0.6,cmap="RdBu_r", add_colorbar=False, rasterized=True)

                ax.coastlines()
                ax.set_global()
                ax.set_title("")

                f.subplots_adjust(left=0.025, right=0.875, bottom=0.05, top=0.95)
                mpu.colorbar(h, ax, extend='both')
                #mpu.colorbar(h, ax, extend='max')
                plt.draw()
                plt.savefig(file, dpi=400, bbox_inches="tight")

