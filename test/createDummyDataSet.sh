#!/bin/bash

# small bash script to create a dummy BIDS data set

# defines where the BIDS data set will be created
StartDir=`pwd` # relative to starting directory
StartDir=$StartDir/dummyData/
mkdir $StartDir

SubList='ctrl01 ctrl02 blind01 blind02 cat01 cat02 cont01 cont02 cont03 01 02' # subject list
SesList='01 02' # session list

for Subject in $SubList # loop through subjects
do

		mkdir $StartDir/sub-$Subject # create folder for subject

		for Ses in $SesList # loop through sessions
		do

			# create folder for each session and functional and fmap
			ThisDir=$StartDir/sub-$Subject/ses-$Ses
			mkdir $ThisDir

			mkdir $ThisDir/func
			touch $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_bold.nii.gz
			touch $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_bold.nii.gz
			touch $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii.gz

			echo "onset,	duration,	trial_type" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vislocalizer_events.tsv
			echo "2,	15,	VisMot" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vislocalizer_events.tsv
			echo "25,	15,	VisStat" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vislocalizer_events.tsv

			echo "onset,	duration,	trial_type" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_events.tsv
			echo "2,	2,	VisMotUp" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_events.tsv
			echo "4,	2,	VisMotDown" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_events.tsv

			echo "onset,	duration,	trial_type" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_events.tsv
			echo "3,	2,	VisMotDown" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_events.tsv
			echo "6,	2,	VisMotUp" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_events.tsv

		  mkdir $ThisDir/anat
		  touch $ThisDir/anat/sub-$Subject\_ses-$Ses\_T1w.nii.gz

		done

done;
