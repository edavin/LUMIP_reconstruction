#!/bin/bash

#
# Step: 3
# Purpose: Create monthly surface temperature (ts) ensemble means and standard deviations of the model responses.
# In: Difference exp-ctr by model; Transient response by model
# Out: Ensemble mean and ensemble standard deviation over models
# path_to_* location specific
#

echo 'its running'

# Ensemble mean out of all model responses (difference exp-ctr)
cdo ensmean /path_to_outputfolder/diff/* /path_to_outputfolder/ensemble_mean_response.nc

# Ensemble standard deviation of all model responsens
cdo ensmean /path_to_outputfolder/exp/std/* /path_to_outputfolder/ensemble_std_response.nc

# Response as ts per emitted tC:
# 2x additional CO2 in atmosphere before sinks (GCP 2018)
# (572-286) doubling of CO2 after pre-Industrial
# x2.13x10xx9 factor ppm to tC
# cdo mulc,2*(572-286)*2.13*10**9
