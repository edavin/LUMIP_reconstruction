#!/usr/bin/env python3
"""
Created 2020

@author: EL Davin
"""

import xarray as xr

##########################################################
# User settings
##########################################################
scen = "low"
out_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
#out_dir = "/net/ch4/landclim/edavin/LUMIP/python/"
#############################################################


#LUH2 v2h has data from 850 to 2015 for states and management and therefore transitions are only until 2014
#The states can be seen as representative of the beginning of the year
#The transitions happen during the year and cause the state in the next year, e.g. 850 transition updates the state from 850 to 851

#first calculate the irrigation "state" as a fraction of the total grid cell
#LUH2 has 100% vegetation fraction in all grid cells, even mountains and deserts.
#therefore LUH2 has to be scaled with a potential vegetation map indicating how much vegetation is in each grid cell

if (scen == "reg"):
    vluh = "v2h"
elif (scen == "high"):
    vluh = "v2h-high"
elif (scen == "low"):
    vluh = "v2h-low"
else:
    print("error, version not found")
    
states_luh2 = "/net/exo/landclim/data/dataset/LUH2/"+vluh+"/0.25deg_lat-lon_1y/original/states.nc"
#manage_luh2 = "/net/exo/landclim/data/dataset/LUH2/"+vluh+"/0.25deg_lat-lon_1y/original/management.nc"
#only crop fraction is different between high and low, while we keep irrig frac from reg
manage_luh2 = "/net/exo/landclim/data/dataset/LUH2/v2h/0.25deg_lat-lon_1y/original/management.nc"

blue = "/net/ch4/landclim/edavin/LUMIP/BLUE/PFT11corr/DBF2CRO_time_reg_gracorr.nc" #only for time axis
potveg = "/net/ch4/landclim/edavin/LUMIP/BLUE/potveg_tropforestoutside40-corr_ratmax.nc"

#calculate total irrigated fraction as a fraction of the grid cell
frac_irr = (xr.open_dataset(states_luh2,decode_times=False).c3ann * xr.open_dataset(manage_luh2,decode_times=False).irrig_c3ann) + (xr.open_dataset(states_luh2,decode_times=False).c4ann * xr.open_dataset(manage_luh2,decode_times=False).irrig_c4ann) + (xr.open_dataset(states_luh2,decode_times=False).c3per * xr.open_dataset(manage_luh2,decode_times=False).irrig_c3per) + (xr.open_dataset(states_luh2,decode_times=False).c4per * xr.open_dataset(manage_luh2,decode_times=False).irrig_c4per) + (xr.open_dataset(states_luh2,decode_times=False).c3nfx * xr.open_dataset(manage_luh2,decode_times=False).irrig_c3nfx)

#frac_irr = frac_irr * potveg

#then calculate the transitions by taking the time derivative
#this will result in a transition matrix with one time step less than the matrix of states (i.e. only until 2014)

time_blue = xr.open_dataset(blue).time

#calculate time derivative and assign time coordinates from BLUE
CROr2CROi = frac_irr.diff("time").assign_coords(time=time_blue)

#CROr2CROi = frac_irr.diff("time",label='lower') #"lower" forces new time coordinate to start at 850 (default would be 850)


#write the transition matrix in the output file
path_file = out_dir+"CROr2CROi_time_"+scen+".nc"
CROr2CROi.to_dataset(name='CROr2CROi').to_netcdf(path=path_file)

