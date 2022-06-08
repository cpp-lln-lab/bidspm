#!/bin/bash

files=$(find ../src -name "*.m")
doc_files=$(find ./source -name "*.rst")

for file in ${files}; do

    this_file=$(basename "${file}" | rev | cut -c 1-2 --complement | rev)

    result=$(grep -r ${this_file} source/*.rst)

    if [ -z "${result}" ]
    then
        echo "- ${this_file} not found"
    fi

done
