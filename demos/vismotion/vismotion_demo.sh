#!/usr/bin/env bash

# fail whenever something is fishy, use -x to get verbose logfiles
set -e -u

# IMPORTANT
#
# For this to work on your system you will need
# to adapt this code to wherever MATLAB is on your computer (Look for the FIXME)
#
# What I used (see the line below) is very likely not where MATLAB lives on your computer
# /usr/local/MATLAB/R2017a/bin/matlab

# create dataset in home dir
datalad create -c yoda ~/visual_motion_localiser
cd ~/visual_motion_localiser

# get code  CPP SPM
datalad install \
    -d . \
    -s https://github.com/cpp-lln-lab/CPP_SPM.git \
    -r \
    code/CPP_SPM

# change branch
cd code/CPP_SPM
git checkout dev
git submodule init
git submodule update
cd ../..

# get data
datalad install -d . \
    --get-data \
    -s git@gin.g-node.org:/cpp-lln-lab/CPP_visMotion-raw.git \
    inputs/raw

datalad save -m 'set up done'

datalad create -d . outputs/derivatives/cpp_spm-preproc
datalad create -d . outputs/derivatives/cpp_spm-stats

cd code/CPP_SPM/demos/vismotion

# FIX ME
/Applications/MATLAB_R2017b.app/bin/matlab \
    -nodisplay -nosplash -nodesktop \
    -r "run('step_1_preprocess.m');exit;"

datalad save -m 'preprocessing done' -r

# FIX ME
/Applications/MATLAB_R2017b.app/bin/matlab \
    -nodisplay -nosplash -nodesktop \
    -r "run('step_2_stats.m');exit;"

datalad save -m 'stats done' -r
