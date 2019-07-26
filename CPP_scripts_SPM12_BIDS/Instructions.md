
# Instructions for SPM12 Preprocessing Pipeline

## Dependencies:

Make sure that the following toolboxes are installed and added to the matlab path.

For instructions see the following links:

 |Dependencies                                                                                               | Used version |
|------------------------------------------------------------------------------------------------------------|--------------|
| [Matlab](https://www.mathworks.com/products/matlab.html)                                                   | 2018a(???)   |
| [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)                                                 | v7487        |
| [Tools for NIfTI and ANALYZE image toolbox](https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image) | NA           |


## Order of the analysis:

1. __Remove Dummy Scans__:
Removes dummy scans by running the script:
`mr_removeDummies.m`

2. __Slice Time Correction__: Performs Slice Time Correction of the functional volumes by running the script:
`mr_batchSPM12_BIDS_STC_ExperimentName.m`

3. __Spatial Preprocessing__:
Performs spatial preprocessing by running the script:
`mr_batchSPM12_BIDS_SpatialPrepro_ExperimentName.m`

4. __SMOOTHING__:
Performs smoothing of the functional data by running the script:
`mr_batchSPM12_BIDS_Smoothing_ExperimentName.m`

5. __FIXED EFFECTS ANALYSIS (FIRST-LEVEL ANALYSIS)__:
Performs the fixed effects analysis by running the ffx script:
`mr_batchSPM12_BIDS_FFX_ExperimentName.m`

This will run twice, once for model specification and another time for model estimation. See the function for more details.

6. __RANDOM EFFECTS ANALYSIS (SECOND-LEVEL ANALYSIS)__:
Performs the random effects analysis by running the RFX script:
`mr_batchSPM12_BIDS_RFX_ExperimentName.m`

- See __"batch.m"__ for examples and for the order of the scripts.
