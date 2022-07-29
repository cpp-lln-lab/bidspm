#!/bin/bash

# [WIP]
# possibly try to set up the API via a python CLI?

set -e -u -x

bids_dir=$1
output_dir=$2
analysis_level=$3
action=$4

OCTFLAGS="--no-gui --no-window-system --silent"

octave $OCTFLAGS --eval "cpp_spm(pwd, pwd, 'group', 'action', 'init'); exit;"

# the following does not work
octave $OCTFLAGS --eval "cpp_spm('${bids_dir}', '${output_dir}', '${analysis_level}', 'action', '${action}'); exit;"
