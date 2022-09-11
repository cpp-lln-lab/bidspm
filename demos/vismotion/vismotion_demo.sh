#!/usr/bin/env bash

# fail whenever something is fishy, use -x to get verbose logfiles
set -e -u

# IMPORTANT
#
# For this to work on your system you will need
# to adapt this code to wherever MATLAB is on your computer (Look for the FIXME)
#
# What I used (see the line below) is very likely not where MATLAB lives on your computer
#
# /usr/local/MATLAB/R2017a/bin/matlab

root_directory="${PWD}/../.."

# create dataset in the home dir
datalad create -c yoda ~/visual_motion_localiser
cd ~/visual_motion_localiser

# get BIDSpm code from the dev branch
source="https://github.com/cpp-lln-lab/CPP_SPM.git"

# for debugging uncomment the follwing line
source=${root_directory}

datalad install \
    -d . \
    --source ${source} \
    --branch dev \
    --recursive \
    code/CPP_SPM

# TODO implement an fmriprep only demo

# get data
datalad install -d . \
    --source git@gin.g-node.org:/cpp-lln-lab/Toronto_VisMotionLocalizer_MR_raw.git \
    --get-data \
    inputs/raw

datalad create -d . outputs/derivatives/cpp_spm-preproc
datalad create -d . outputs/derivatives/cpp_spm-stats

cd code/CPP_SPM/demos/vismotion

# FIX ME
/usr/local/MATLAB/R2017a/bin/matlab \
    -nodisplay -nosplash -nodesktop \
    -r "run('step_1_preprocess.m');exit;"

datalad save -d ../../../.. -m 'preprocessing done' --recursive

# FIX ME
/usr/local/MATLAB/R2017a/bin/matlab \
    -nodisplay -nosplash -nodesktop \
    -r "run('step_2_stats.m');exit;"

datalad save -d ../../../.. -m 'stats done' --recursive
