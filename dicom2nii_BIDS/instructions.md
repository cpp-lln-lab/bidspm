
# Instructions #

## Dependancies:##
- dcm2Bids
- dcm2niix  
Make sure that dcm2Bids and dcm2niix are installed.
for instructions see the following Link: _https://github.com/cbedetti/Dcm2Bids_

## STEP 1 ##
- Open the shell script "dicom2nii_BIDS_Step1.sh" in your preferred text editor.
- Change your desired BIDS output directory.

- Add the different groups of subjects and their names, and DICOM locations
- Run the dicom2nii_BIDS_Step1.sh in the terminal: ./sh dicom2nii_BIDS_Step1.sh
- Go to your BIDS output directory and then to the tmp_dcm2bids folder
- Open the json files of the different conditions and get the _SERIES DISCRIPTION_ ,
eg: "SeriesDescription": "Motion" --> here the Series description is Motion.
- Create a new json file called config.json in the BIDS output directory. Add the conditions indicating the series description. Check the "config.json" for examples and the "config_json_template_different_modalities.json" for all possible modalities


## STEP 2 ##
- Open the shell script "dicom2nii_BIDS_Step2.sh" in your preferred text editor.
- Change your desired BIDS output directory, add the different groups of subjects and their names, and DICOM locations. __MAKE SURE IT MATCHS STEP1__

- repeat the blocks of code for each condition in your experiment (eg. anatomical, functional exp1, functional exp2, etc.)
- Make sure that the dicom location in each experimental condition is correct.
- Run the dicom2nii_BIDS_Step2.sh in the terminal: ./sh dicom2nii_BIDS_Step2.sh
- move the produced subject folders in a folder called 'raw' to kept as the untouched raw data.
- copy the contents of the raw folder in the 'derivatives' folder
- Check the dataset whether its compatible with the BIDS guidelines: https://github.com/bids-standard/bids-validator
- fix the errors until its compatible.
