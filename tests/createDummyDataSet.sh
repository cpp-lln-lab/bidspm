#!/bin/bash

# small bash script to create a dummy BIDS data set

# defines where the BIDS data set will be created
StartDir=`pwd` # relative to starting directory
StartDir=$StartDir/dummyData/derivatives/SPM12_CPPL
mkdir $StartDir

SubList='ctrl01 ctrl02 blind01 blind02 01 02' # subject list
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

			rm $ThisDir/func/*

			touch $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_bold.nii
			touch $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_bold.nii
			touch $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii

			touch $ThisDir/func/asub-$Subject\_ses-$Ses\_task-vismotion_run-1_bold.nii
			touch $ThisDir/func/asub-$Subject\_ses-$Ses\_task-vismotion_run-2_bold.nii

			touch $ThisDir/func/meanusub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/func/s6wsub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/func/s6rsub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/func/s6usub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/func/rp_sub-$Subject\_ses-$Ses\_task-vislocalizer_bold.txt

			echo "onset\tduration\ttrial_type" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vislocalizer_events.tsv
			echo "2\t15\tVisMot" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vislocalizer_events.tsv
			echo "25\t15\tVisStat" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vislocalizer_events.tsv

			echo "onset\tduration\ttrial_type" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_events.tsv
			echo "2\t2\tVisMotUp" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_events.tsv
			echo "4\t2\tVisMotDown" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_events.tsv

			echo "onset\tduration\ttrial_type" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_events.tsv
			echo "3\t2\tVisMotDown" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_events.tsv
			echo "6\t2\tVisMotUp" >> $ThisDir/func/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_events.tsv

		  mkdir $ThisDir/anat

		  touch $ThisDir/anat/sub-$Subject\_ses-$Ses\_T1w.nii

		done

done;
