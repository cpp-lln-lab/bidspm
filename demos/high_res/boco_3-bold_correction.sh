#!/bin/bash

# --- import parameters

source config.sh

#-------------------------------------------------------------------------------
echo ""
echo "BOLD CORRECTION"
#-------------------------------------------------------------------------------

nb_runs=$(find "${input_dir}" -name "sub-${sub_label}*_vaso.nii" | wc -l)

echo ${nb_runs}

for iRun in $(seq 1 ${nb_runs}); do

    vaso_file=$(find "${input_dir}" -name "upsmpl_tempco_moco_sub-${sub_label}*run-*${iRun}_vaso.nii")
    bold_file=$(find "${input_dir}" -name "upsmpl_tempco_moco_sub-${sub_label}*run-*${iRun}_bold.nii")

    "${laynii}"/LN_BOCO \
        -Nulled "${vaso_file}" \
        -BOLD "${bold_file}"
    # -trialBOCO 40

    echo ""
    echo "Correcting for the proper TR in the header"

    "${afni}"/3drefit \
        -TR ${bold_tr} \
        "${bold_file}"

    vaso_file=$(find "${input_dir}" -name "upsmpl_tempco_moco_sub-${sub_label}*run-*${iRun}_vaso_VASO_LN.nii")

    "${afni}"/3drefit \
        -TR ${vaso_tr} \
        "${vaso_file}"

done
