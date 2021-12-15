#!/bin/bash

#
# Step: 2
# Purpose: Create monthly surface temperature (ts) differences between pre-industrial (pi) and transient experiment means.
# In: pi and transient experiment (exp) mean surface temperature by model from "monmean-picontrol.sh" and "monmean_transient.sh"
# Out: Monthly transient surface temperature response (difference exp-ctr) to CO2 doubling  by model in "ModelName"
# path_to_* location specific
#

echo 'its running'

ModelName="ACCESS1-0 bcc-csm1-1 BNU-ESM CCSM4 CNRM-CM5 CSIRO-Mk3-6-0 EC-EARTH FGOALS-s2 GFDL-ESM2G GISS-E2-H HadGEM2-ES ACCESS1-3 bcc-csm1-1-m CanESM2 CNRM-CM5-2 CSIRO-Mk3L-1-2 FGOALS-g2 GFDL-CM3 GFDL-ESM2M GISS-E2-R inmcm4"

# Data in
for val in $ModelName; do
expPath=/path_to_outputfolder/exp/monmean_
piPath=/path_to_outputfolder/pi/monmean_


filename=$(basename "$val")
fname="${filename%.*}"



# Monthly  difference exp-ctr
echo $filename
ncdiff ${expPath}${val}.nc ${piPath}${val}.nc /path_to_outputfolder/diff/mondiff_${filename}.nc


done
