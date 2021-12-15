#!/bin/bash

#
# Step: 1
# Purpose: Create monthly transient (70yrs +/- 20yrs) surface temperature (ts) mean response to doubling of CO2.
# In: CMIP5 +1%CO2/a experiment model output
# Out: Transient monthly mean surface temperature by model in "ModelName"
# path_to_* location specific
#


echo 'its running'

ModelName="ACCESS1-0 bcc-csm1-1 BNU-ESM CCSM4 CNRM-CM5 CSIRO-Mk3-6-0 EC-EARTH FGOALS-s2 GFDL-ESM2G GISS-E2-H HadGEM2-ES ACCESS1-3 bcc-csm1-1-m CanESM2 CNRM-CM5-2 CSIRO-Mk3L-1-2 FGOALS-g2 GFDL-CM3 GFDL-ESM2M GISS-E2-R inmcm4"

# Data in
for val in $ModelName; do
ModelPath=/path_to_cmip5_output/cmip5/1pctCO2/Amon/ts/${val}/r1i1p1/

filename=$(basename "$val")
fname="${filename%.*}"

# Merge split datasets by date and time to temp folder
cd $ModelPath
cdo mergetime *.nc /path_to_tempfolder/tmp/tmp1.nc

# Monthly means of each model in "ModelName". Considering the time 20yrs before and after doubling of CO2 (50-90yrs / 600-1080 months).
echo $filename
cdo -ymonmean -seltimestep,600/1080 -remapbil,r360x180 /path_to_tempfolder/tmp/tmp1.nc "/path_to_outputfolder/exp/monmean_${filename}.nc"


# Remove intermediate files created in temp folder
rm /path_to_tempfolder/tmp/tmp1.nc
done
