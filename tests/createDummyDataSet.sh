#!/bin/bash

# small bash script to create a dummy BIDS data set

# defines where the BIDS data set will be created
StartDir=`pwd` # relative to starting directory
StartDir=$StartDir/dummyData/derivatives/cpp_spm
mkdir $StartDir

SubList='ctrl01 ctrl02 blind01 blind02 01 02' # subject list
SesList='01 02' # session list

for Subject in $SubList # loop through subjects
do

		mkdir $StartDir/sub-$Subject # create folder for subject

		for Ses in $SesList # loop through sessions
		do

			# create folder for each session and functional and fmap
			mkdir $StartDir/sub-$Subject/ses-$Ses
			ThisDir=$StartDir/sub-$Subject/ses-$Ses/func
			mkdir $ThisDir

			# FUNC
			rm $ThisDir/func/*

			touch $ThisDir/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_bold.nii
			touch $ThisDir/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_bold.nii
			touch $ThisDir/asub-$Subject\_ses-$Ses\_task-vismotion_run-1_bold.nii
			touch $ThisDir/asub-$Subject\_ses-$Ses\_task-vismotion_run-2_bold.nii


			touch $ThisDir/sub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/meanusub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/s6wsub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/s6rsub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/s6usub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/s6wusub-$Subject\_ses-$Ses\_task-vislocalizer_bold.nii
			touch $ThisDir/rp_sub-$Subject\_ses-$Ses\_task-vislocalizer_bold.txt

			echo "onset\tduration\ttrial_type" >> $ThisDir/sub-$Subject\_ses-$Ses\_task-vislocalizer_events.tsv
			echo "2\t15\tVisMot" >> $ThisDir/sub-$Subject\_ses-$Ses\_task-vislocalizer_events.tsv
			echo "25\t15\tVisStat" >> $ThisDir/sub-$Subject\_ses-$Ses\_task-vislocalizer_events.tsv

			echo "onset\tduration\ttrial_type" >> $ThisDir/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_events.tsv
			echo "2\t2\tVisMotUp" >> $ThisDir/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_events.tsv
			echo "4\t2\tVisMotDown" >> $ThisDir/sub-$Subject\_ses-$Ses\_task-vismotion_run-1_events.tsv

			echo "onset\tduration\ttrial_type" >> $ThisDir/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_events.tsv
			echo "3\t2\tVisMotDown" >> $ThisDir/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_events.tsv
			echo "6\t2\tVisMotUp" >> $ThisDir/sub-$Subject\_ses-$Ses\_task-vismotion_run-2_events.tsv

		done

		# ANAT
		ThisDir=$StartDir/sub-$Subject/ses-01/anat
		mkdir $ThisDir

		touch $ThisDir/sub-$Subject\_ses-01_T1w.nii
		touch $ThisDir/msub-$Subject\_ses-01_T1w.nii
		touch $ThisDir/wmsub-$Subject\_ses-01_T1w.nii
		touch $ThisDir/c1sub-$Subject\_ses-01_T1w.nii
		touch $ThisDir/c2sub-$Subject\_ses-01_T1w.nii
		touch $ThisDir/c3sub-$Subject\_ses-01_T1w.nii

		# STATS
		mkdir $StartDir/sub-$Subject/stats
		mkdir $StartDir/sub-$Subject/stats/ffx_task-vismotion/
		mkdir $StartDir/sub-$Subject/stats/ffx_task-vismotion/ffx_space-MNI_FWHM-6
		touch $StartDir/sub-$Subject/stats/ffx_task-vismotion/ffx_space-MNI_FWHM-6/mask.nii

done;
