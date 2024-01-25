#! /bin/bash

# script to run the demo via the command line
cd ../..

bidspm demos/openneuro/inputs/ds000001 demos/openneuro/outputs/ds000001/derivatives subject \
    --action preprocess \
    --task balloonanalogrisktask \
    --fwhm 8 \
    --participant_label 01 02 03
