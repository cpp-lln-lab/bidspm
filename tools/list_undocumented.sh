#!/bin/bash

# simple script to list functions of the source folder
# that are not listed in the doc

src_folder="../src"
doc_folder="../docs/source"

files=$(find ${src_folder} -name "*.m")

for file in ${files}; do

    this_file=$(basename "${file}" | rev | cut -c 1-2 --complement | rev)

    result_rst=$(grep -r "${this_file}" ${doc_folder}/*.rst)
    result_md=$(grep -r "${this_file}" ${doc_folder}/*.md)

    if [ -z "${result_rst}" ] && [ -z "${result_md}" ]; then
        echo "- ${this_file} not found"
    fi

done
