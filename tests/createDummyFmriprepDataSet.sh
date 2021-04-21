#!/bin/bash

# small bash script to create a dummy fmriprep data set

space='MNI152NLin2009cAsym'
task='rest'

# defines where the BIDS data set will be created
StartDir=`pwd` # relative to starting directory
PreprocDir=$StartDir/dummyData/derivatives/fmriprep

SubList='ctrl01 blnd01' # subject list

for Subject in $SubList
do

		mkdir $PreprocDir/sub-$Subject

		# FUNC
		ThisDir=$PreprocDir/sub-$Subject/func
		mkdir $ThisDir

	    basename=sub-$Subject\_task-$task\_run-01_space-$space

		echo $basename

		touch $ThisDir/$basename\_desc-preproc_bold.nii
		echo "{\"RepetitionTime\": 0.785, \"SkullStripped\": false}" > \
			  $ThisDir/$basename\_desc-preproc_bold.json

		touch $ThisDir/$basename\_desc-brain_mask.nii
		touch $ThisDir/$basename\_boldref.nii

		# ANAT
		ThisDir=$PreprocDir/sub-$Subject/anat
		mkdir $ThisDir

		touch $ThisDir/sub-$Subject\_space-$space\_desc-preproc_T1w.nii
		echo "{\"SkullStripped\": false}" > \
			  $ThisDir/sub-$Subject\_space-$space_\desc-preproc_T1w.json

done;
