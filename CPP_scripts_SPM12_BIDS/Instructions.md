
# Instructions for SPM12 Preprocessing Pipeline

## Dependancies:##
- SPM12
- Tools for NIfTI and ANALYZE image toolbox. <br />

Make sure that the SPM12 and the NIfTI toolbox are installed and added to the matlab path.
for instructions see the following Links: <br />
NIfTI toolbox: _https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image_ <br />
SPM12: _https://www.fil.ion.ucl.ac.uk/spm/software/spm12/_

## Order of the analysis:

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
