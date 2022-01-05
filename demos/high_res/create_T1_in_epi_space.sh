#!/bin/bash

# --- import parameters

source config.sh

#-------------------------------------------------------------------------------
echo ""
echo "calculating T1 in EPI space"
#-------------------------------------------------------------------------------
# run for only run1
# TODO use the mean image instead ?

vaso_file=$(find "${input_dir}" -name "moco_sub-${sub_label}*run-*1_vaso.nii")
bold_file=$(find "${input_dir}" -name "moco_sub-${sub_label}*run-*1_bold.nii")

NumVol=$("${afni}"/3dinfo -nv "${vaso_file}")

"${afni}"/3dcalc \
    -a "${vaso_file}"'[3..'$(expr $NumVol - 2)']' \
    -b "${bold_file}"'[3..'$(expr $NumVol - 2)']' \
    -expr 'a+b' \
    -prefix combined.nii \
    -overwrite

output_T1=$(echo "${bold_file}" | sed s/_bold/_T1w/g)

"${afni}"/3dTstat \
    -cvarinv \
    -prefix "${output_T1}" \
    -overwrite combined.nii

rm combined.nii
