#!/bin/bash

files=$(find ../src -name "*.m")
doc_files=$(find ./source -name "*.rst")

echo "${doc_files}"

for file in ${files}; do

    this_file=$(basename "${file}")
    echo ${this_file}

done
