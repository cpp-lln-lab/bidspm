#!/bin/bash

# simple script to list functions of the source folder
# that are not mentioned in the rest of source folder
# and is potential dead code

src_folder="../src"

files=$(find ${src_folder} -name "*.m")

for file in ${files}; do

    this_file=$(basename "${file}" | rev | cut -c 1-2 --complement | rev)

    results=$(grep -or "${this_file}" ${src_folder})

    nb_lines=$(wc -l <<< "${results}")

    if [ "${nb_lines}" -lt 2 ]; then
        echo
        echo "---------------------------------------------------------------------"
        echo ${file}
        echo ${this_file}
        echo
        for line in ${results}; do
            echo $line
        done
    fi

done
