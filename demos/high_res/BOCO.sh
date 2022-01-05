#!/bin/bash

echo "The script starts now:  I expect two files Not_Nulled_Basis.nii and Nulled_Basis_b.nii that are motion corrected with SPM"


echo "temporal upsampling and shifting happens now"

for runNb in {1..6}
do
   echo ""
   echo "run $i "
   echo ""


$HOME/abin/3dcalc \
    -a moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii'[0..$(2)]' \
    -expr 'a' \
    -prefix tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii \
    -overwrite
$HOME/abin/3dcalc \
    -a moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_bold.nii'[1..$(2)]' \
    -expr 'a' \
    -prefix tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_bold.nii \
    -overwrite

$HOME/abin/3dUpsample \
    -overwrite  \
    -datum short \
    -prefix upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii \
    -n 2 \
    -input tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii
$HOME/abin/3dUpsample \
    -overwrite  \
    -datum short \
    -prefix upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_bold.nii \
    -n 2 \
    -input tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_bold.nii

NumVol=`$HOME/abin/3dinfo -nv upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_bold.nii`
$HOME/abin/3dTcat \
    -overwrite \
    -prefix upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii \
    upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii'[0]' \
    upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii'[0..'`expr $NumVol - 2`']' 

echo "BOLD correction happens now"
# /Users/barilari/data/tools/LAYNII/LN_BOCO \
    # -Nulled upsmpl_tempco_moco_run${runNb}_4D_vaso.nii \
    # -BOLD upsmpl_tempco_moco_run${runNb}_4D_bold.nii \
    # -trialBOCO 40
/Users/barilari/data/tools/LAYNII/LN_BOCO \
    -Nulled upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii \
    -BOLD upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_bold.nii


echo "I am correcting for the proper TR in the header"
$HOME/abin/3drefit \
    -TR 2.25 \
    upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_bold.nii
$HOME/abin/3drefit \
    -TR 1.6 \
    upsmpl_tempco_moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso_VASO_LN.nii

# run for only run1
echo "calculating T1 in EPI space"
NumVol=`$HOME/abin/3dinfo -nv moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii`
$HOME/abin/3dcalc \
    -a moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_vaso.nii'[3..'`expr $NumVol - 2`']' \
    -b moco_sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_bold.nii'[3..'`expr $NumVol - 2`']' \
    -expr 'a+b' -prefix combined.nii -overwrite
$HOME/abin/3dTstat \
    -cvarinv \
    -prefix sub-pilot001_ses-008_task-gratingBimodalMotion_run-00${runNb}_epiT1w.nii \
    -overwrite combined.nii 
rm combined.nii

done

# echo "calculating Mean and tSNR maps"
# $HOME/abin/3dTstat \
#     -mean \
#     -prefix mean_nulled.nii \
#     tempco_moco_run${runNb}_4D_vaso.nii \
#     -overwrite
# $HOME/abin/3dTstat \
#     -mean \
#     -prefix mean_notnulled.nii \
#     tempco_moco_run${runNb}_4D_bold.nii \
#     -overwrite
# $HOME/abin/3dTstat  \
#     -overwrite \
#     -mean  \
#     -prefix BOLD.Mean.nii \
#     upsmpl_tempco_moco_run${runNb}_4D_bold.nii'[1..$]'
# $HOME/abin/3dTstat  \
#     -overwrite \
#     -cvarinv  \
#     -prefix BOLD.tSNR.nii \
#     upsmpl_tempco_moco_run${runNb}_4D_bold.nii'[1..$]'
# $HOME/abin/3dTstat  \
#     -overwrite \
#     -mean  \
#     -prefix VASO.Mean.nii \
#     upsmpl_tempco_moco_run${runNb}_4D_vaso_VASO_LN.nii'[1..$]'
# $HOME/abin/3dTstat  \
#     -overwrite \
#     -cvarinv  \
#     -prefix VASO.tSNR.nii \
#     upsmpl_tempco_moco_run${runNb}_4D_vaso_VASO_LN.nii'[1..$]'

# echo "curtosis and skew"
# /Users/barilari/data/tools/LAYNII/LN_SKEW \
    # -input tempco_moco_run${runNb}_4D_bold.nii
# /Users/barilari/data/tools/LAYNII/LN_SKEW \
    # -input upsmpl_tempco_moco_run${runNb}_4D_vaso_VASO_LN.nii
