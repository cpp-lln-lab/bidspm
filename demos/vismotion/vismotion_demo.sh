#!/usr/bin/env bash

# fail whenever something is fishy, use -x to get verbose logfiles
set -e -u -x

# IMPORTANT
#
# For this to work on your system you will need
# to adapt this code to wherever MATLAB is on your computer (Look for the FIXME)
#
# What I used (see the line below) is very likely not where MATLAB lives on your computer
#
# /usr/local/MATLAB/R2018a/bin/matlab

yoda_dir=~/visual_motion_localiser

# create a new dataset if it doesn't exist
if [ ! -d ${yoda_dir} ]; then

    # create dataset in the home dir
    datalad create -c yoda ${yoda_dir}
    cd ${yoda_dir}

    # get data
    datalad install -d ${yoda_dir} \
        --source git@gin.g-node.org:/cpp-lln-lab/Toronto_VisMotionLocalizer_MR_raw.git \
        --get-data \
        --jobs 12 \
        inputs/raw

    datalad create -d ${yoda_dir} outputs/derivatives/bidspm-preproc
    datalad create -d ${yoda_dir} outputs/derivatives/bidspm-stats

fi

# install bidspm if it doesn't exist
if [ ! -d "${yoda_dir}/code/bidspm" ]; then

    echo "installing bidspm in ${yoda_dir}/code/bidspm"

    # get bidspm code
    source="https://github.com/cpp-lln-lab/bidspm.git"

    # for debugging uncomment the following lines

    # # directory of this script
    # script_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    # root_directory="${script_directory}/../.."
    # # absolute path of root directory
    # root_directory="$(readlink -f ${root_directory})"
    # source=${root_directory}

    echo "from ${source}"

    datalad install \
        -d ${yoda_dir} \
        --source ${source} \
        --recursive \
        ${yoda_dir}/code/bidspm

    # TODO: implement via bidspm bids app CLI only
    # cd code/bidspm
    # pip install .
    # cd ../..

fi

cd ${yoda_dir}/code/bidspm/demos/vismotion

# FIX ME
/usr/local/MATLAB/R2018a/bin/matlab \
    -nodisplay -nosplash -nodesktop \
    -r "run('step_1_preprocess.m');exit;"

datalad save -d ${yoda_dir} -m 'preprocessing done' --recursive

# FIX ME
/usr/local/MATLAB/R2018a/bin/matlab \
    -nodisplay -nosplash -nodesktop \
    -r "run('step_2_stats.m');exit;"

datalad save -d ${yoda_dir} -m 'stats done' --recursive
