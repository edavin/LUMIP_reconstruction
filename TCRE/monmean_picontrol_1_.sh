#!/bin/bash

#
# Step: 1
# Purpose: Create monthly Pre-Industrial (pi) surface temperature (ts) means.
# In: CMIP5 pre-industrial model output
# Out: Pre-industrial monthly mean surface temperature by model in "ModelName"
# path_to_* location specific
#


echo 'its running'

ModelName="ACCESS1-0 bcc-csm1-1 BNU-ESM CCSM4 CNRM-CM5 CSIRO-Mk3-6-0 EC-EARTH FGOALS-s2 GFDL-ESM2G GISS-E2-H HadGEM2-ES ACCESS1-3 bcc-csm1-1-m CanESM2 CNRM-CM5-2 CSIRO-Mk3L-1-2 FGOALS-g2 GFDL-CM3 GFDL-ESM2M GISS-E2-R inmcm4"

# Data in
for val in $ModelName; do
ModelPath=/path_to_cmip5_output/cmip5/piControl/Amon/ts/${val}/r1i1p1/

filename=$(basename "$val")
fname="${filename%.*}"

# Merge split datasets by date and time to temp folder
cd $ModelPath
cdo mergetime *.nc /path_to_tempfolder/tmp/tmp1.nc

# Monthly means of each model in "ModelName". Considering the last 50 years of each run (600 months) to allow for ramp up.
echo $filename
cdo -ymonmean -seltimestep,-600/-1 -remapbil,r360x180 /path_to_tempfolder/tmp/tmp1.nc "/path_to_outputfolder/pi/monmean_${filename}.nc"


# Remove intermediate files created in temp folder
rm /path_to_tempfolder/tmp/tmp1.nc
done
