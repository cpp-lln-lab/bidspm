# to run the script, open the terminal and run: 
# sh./ dicom2nii_BIDS_Step2.sh


# The following script using dcm2bids and dcm2niix to convert DICOMS
# to a BIDS compaitable format.
# To install dcm2bids: https://pypi.org/project/dcm2bids/

# BIDS outout folder
BIDSOutputFolder=/Users/mohamed/Desktop/BIDS_V4/

# if BIDSOutputFolder does not exist
if [ ! -d $BIDSOutputFolder ]; then
  mkdir -p $BIDSOutputFolder;    # Create directory
fi

########################################
##############   GROUP 1   #############
########################################
# Subject Names (folder names)
#Subjs=("GeAl"	"MaGa"	"OlCo"	"PiMa"	"SyNo"	"ViCh"	"WiAu" "JoFr"	"MpLa"	"PhAL"	"SiGi"	"VaLa"	"ViCr")
Subjs=("GeAl"	"MaGa") #	"OlCo"	"PiMa"	"SyNo"	"ViCh"	"WiAu" "JoFr"	"MpLa"	"PhAL"	"SiGi"	"VaLa"	"ViCr")
group='con'     # Group
dicomsRootFolder=/Data/Neurocat_BIDS/DICOMS/Control/      # DICOMS root folder

########################################
##############   GROUP 2   #############
########################################
#Subjs=("AlBo"	"CaBa"	"CaPi"	"ChRe"	"IaWa"	"JoSn"	"MiDo"	"NaAs"	"SaAt"	"WiSn"	"ZaCr")
##Subjs=("AlBo"	"CaBa")
#group='cat'
#dicomsRootFolder=/Data/Neurocat_BIDS/DICOMS/Cataract/      # DICOMS root folder

########################################

# Go to the BIDS output directory
cd $BIDSOutputFolder

# dcm2bids_scaffold creates the neccessary folders and files for the BIDS structure
#dcm2bids_scaffold

# Run the dcm2bids_helper -d $dicomsRootFolder on a couple of subjects to get the information regarding
# the name of the conditions and files.
# This information will used in the config.json file
#dcm2bids_helper -d $dicomsRootFolder

#echo "##############################################################"
#echo "Create the config.json in the BIDS output directory."
#echo "and add the required information before running step 2 "
#echo "The information is available in tmp_dcm2bids json files"
#echo "##############################################################"

# MAKE SURE THAT YOU HAVE THE config.json file ready at this step and filled correctly for the different
# experiment names.

# Get the number of the subjects in the group
NrSubjs=${#Subjs[@]}
echo 'Number of Subjects: '$NrSubjs

## loop through the different subjects
# for loop that iterates over each element in arr
for iSub in "${!Subjs[@]}" #{1..$NrSubjs}
do
    iSubNum="$(printf "%02d" $(($iSub+1)))"  # Get the subject Number
    SubName="${Subjs[iSub]}"                 # Get the subject Name

# For every condition you have, add the following block of code to get the DICOM location

## 1. ANATOMICAL
    # the directory to the dicom files (needs to be changed according to your dicom location and name)
    subDicomFolder=$dicomsRootFolder$SubName'/Anatomical'           ## <---------- CHANGE THE LOCATION
    #subOutputFolder=$BIDSOutputFolder
    #echo $SubName $iSubNum $subOutputFolder
    echo "DICOMS folder is: "$subDicomFolder
    echo "Output folder is: "$BIDSOutputFolder
  dcm2bids -d $subDicomFolder -p $group$iSubNum -s 01 -c config.json -o $BIDSOutputFolder

################################################################################
# dcm2bids inputs:
# dcm2bids -d $subDicomFolder -p $group$iSubNum -s 01 -c config.json -o $BIDSOutputFolder
# -d : DICOM PATH
# -p Partipiant name/number and the (group)
# -s Session number
# -o output directory for the nifti files
# -c Configuration json file that should be present in the output directory
################################################################################

  ## 2. Functional data - Name of the experiment: DECODING
  subDicomFolder=$dicomsRootFolder$SubName'/Motion'                 ## <---------- CHANGE THE LOCATION
  echo "DICOMS folder is: "$subDicomFolder
  echo "Output folder is: "$BIDSOutputFolder
  dcm2bids -d $subDicomFolder -p $group$iSubNum -s 01 -c config.json -o $BIDSOutputFolder


  ## 3. ADD OTHER EXPERIMENTS IF NEEDED BY COPYING ONE OF THE ABOVE


done
