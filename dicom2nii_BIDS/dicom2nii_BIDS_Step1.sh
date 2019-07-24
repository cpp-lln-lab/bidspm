# to run the script, open the terminal and run:
# sh./ dicom2nii_BIDS_Step1.sh


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
dcm2bids_scaffold

# Run the dcm2bids_helper -d $dicomsRootFolder on a couple of subjects to get the information regarding
# the name of the conditions and files. The information is available in output json files in the "tmp_dcm2bids"
# This information will used in the config.json file
dcm2bids_helper -d $dicomsRootFolder

echo "##############################################################"
echo "Create the config.json in the BIDS output directory."
echo "and add the required information before running step 2 "
echo "The information is available in tmp_dcm2bids json files"
echo "##############################################################"

# MAKE SURE THAT YOU HAVE THE config.json file ready at this step and filled correctly for the different
# experiment names.
