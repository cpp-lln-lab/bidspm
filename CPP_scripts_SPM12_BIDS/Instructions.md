
# Instructions for SPM12 Preprocessing Pipeline

## Order of the analysis:
batch.m
getData.m
mat2tsv.m
1. __Remove Dummy Scans__:
Remove Dummy scans by running the script: _"mr_removeDummies.m"_
2. __Slice Time Correction__: Perform Slice Time Correction of the functional volumes by running the script: _"mr_batchSPM12_BIDS_STC_ExperimentName.m"_
3. __Spatial Preprocessing__:
Perform spatial preprocessing by running the script: _"mr_batchSPM12_BIDS_SpatialPrepro_ExperimentName.m"_

4. __SMOOTHING__:
Perform smoothing of the functional data by running the script: _"mr_batchSPM12_BIDS_Smoothing_ExperimentName.m"_

5. __FIXED EFFECTS ANALYSIS (FIRST-LEVEL ANALYSIS)__:
Perform the fixed effects analysis by running the ffx script:   _"mr_batchSPM12_BIDS_FFX_ExperimentName.m"_
This will run twice, once for model specification and another time for model estimation. See the function for more details.
6. __RANDOM EFFECTS ANALYSIS (SECOND-LEVEL ANALYSIS)__: Perform the random effects analysis by running the RFX script: _"mr_batchSPM12_BIDS_RFX_ExperimentName.m"_

- See __"batch.m"__ for examples and for the order of the scripts.
