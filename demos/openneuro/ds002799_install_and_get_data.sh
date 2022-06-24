#! /bin/bash

datalad install --source ///openneuro/ds002799 inputs/ds002799

cd inputs/ds002799/derivatives/fmriprep

datalad get sub-29*/*/func/*MNI152NLin2009cAsym*
datalad get sub-29*/*/func/*tsv
datalad get sub-30*/*/func/*MNI152NLin2009cAsym*
datalad get sub-30*/*/func/*tsv
