#!/bin/bash

# --- import parameters

source config.sh

#-------------------------------------------------------------------------------
echo ""
echo "temporal upsampling"
#-------------------------------------------------------------------------------

for suffix in ${suffixes}; do

    inputs_files=$(find "${input_dir}" -name "moco_sub-${sub_label}*_${suffix}.nii")

    for input_file in ${inputs_files}; do

        echo ""
        echo "processing:" "${input_file}"

        if [[ "${suffix}" == "vaso" ]]; then
            first_vol="${first_vol_vaso}"
        else
            first_vol="${first_vol_bold}"
        fi

        output_file=$(echo "${input_file}" | sed 's/moco_/tempco_moco_/g')

        vol_to_select='['"${first_vol}"'..$(2)]'

        "${afni}"/3dcalc \
            -a "${input_file}""${vol_to_select}" \
            -expr 'a' \
            -prefix "${output_file}" \
            -overwrite

    done

done

for suffix in ${suffixes}; do

    inputs_files=$(find "${input_dir}" -name "tempco_moco_sub-${sub_label}*_${suffix}.nii")

    for input_file in ${inputs_files}; do

        echo ""
        echo "processing:" "${input_file}"

        output_file=$(echo "${input_file}" | sed 's/tempco_/upsmpl_tempco_/g')

        "${afni}"/3dUpsample \
            -input "${input_file}" \
            -datum short \
            -n 2 \
            -prefix "${output_file}" \
            -overwrite

    done

done
