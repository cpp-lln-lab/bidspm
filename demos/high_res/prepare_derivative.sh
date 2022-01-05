#!/bin/bash

clear

# --- import parameters

source config.sh

# --- run
input_files=$(find "${input_dir}" -name "*_boldcbv.nii")

echo "${input_files}"

for input_file in ${input_files}; do
    echo ""
    echo "processing:" "${input_file}"
    echo ""

    output_dir=$(dirname "${input_file}")
    output_file="${output_dir}/tmp.nii"

    ## duplicate the func image
    cp -v "${input_file}" "${output_file}"

    ## remove 4 dummies cause we are not in steady state just yet
    $HOME/abin/3dTcat -prefix "${output_file}" \
        $output_file'['$nb_dummies'..7]' \
        $output_file'['$nb_dummies'..$]' \
        -overwrite

    ## duplicate again
    output_bold=$(echo ${input_file} | sed "s/_boldcbv.nii/_bold.nii/g")
    cp -v "${output_file}" "${output_bold}"
    output_vaso=$(echo ${input_file} | sed "s/_boldcbv.nii/_vaso.nii/g")
    cp -v "${output_file}" "${output_vaso}"

    rm "${output_file}"

done

# rm "${input_files}"
