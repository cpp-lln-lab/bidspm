#!/bin/bash

# --- import parameters

source config.sh

#-------------------------------------------------------------------------------
echo ""
echo "temporal shifting"
#-------------------------------------------------------------------------------

vaso_files=$(find "${input_dir}" -name "upsmpl_tempco_moco_sub-${sub_label}*_vaso.nii")

for vaso_file in ${vaso_files}; do

    NumVol=$($HOME/abin/3dinfo -nv "${vaso_file}")
    "${afni}"/3dTcat \
        "${vaso_file}"'[0]' \
        "${vaso_file}"'[0..'$(expr ${NumVol} - 2)']' \
        -prefix "${vaso_file}" \
        -overwrite

done
