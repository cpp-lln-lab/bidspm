#!/bin/bash

# small bash script to create a dummy BIDS data set

# defines where the BIDS data set will be created
start_dir=`pwd` # relative to starting directory
preproc_dir=${start_dir}/dummyData/derivatives/cpp_spm-preproc
stats_dir=${start_dir}/dummyData/derivatives/cpp_spm-stats

subject_list='ctrl01 ctrl02 blind01 blind02 01 02' # subject list
session_list='01 02' # session list

for subject in ${subject_list}
do

		for ses in ${session_list}
		do

			# FUNC
			this_dir=${preproc_dir}/sub-${subject}/ses-${ses}/func
			mkdir -p ${this_dir}

			## task: vismotion
			suffix='_bold'
			task_name='vismotion'

			### raw
			touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_run-1${suffix}.nii
			echo "{\"TaskName\": \"vislocalizer\"}" > ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_run-1${suffix}.json
			touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_run-2${suffix}.nii
			echo "{\"TaskName\": \"vislocalizer\"}" > ${this_dir}/sub-${subject}\_ses-${ses}\

			touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}\_acq-1p60mm\_run-1${suffix}.nii
			touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}\_acq-1p60mm\_dir-PA_run-1${suffix}.nii

			filename=${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_run-1_events.tsv
			echo "onset\tduration\ttrial_type" > ${filename}
			echo "2\t2\tVisMotUp" >> ${filename}
			echo "4\t2\tVisMotDown" >> ${filename}

			filename=${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_run-2_events.tsv
			echo "onset\tduration\ttrial_type" > ${filename}
			echo "3\t2\tVisMotDown" >> ${filename}
			echo "6\t2\tVisMotUp" >> ${filename}

			### derivatives
			desc_label_list='stc preproc mean smth6'
			for desc in ${desc_label_list}
			do
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_run-1\_space-individual\_desc-${desc}${suffix}.nii
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_run-2\_space-individual\_desc-${desc}${suffix}.nii
			done
			touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_run-1\_space-IXI549Space\_desc-preproc${suffix}.nii
			touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_run-2\_space-IXI549Space\_desc-preproc${suffix}.nii

			if [ ${ses} = '01' ]; then
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}\_space-individual\_desc-mean${suffix}.nii
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}\_space-IXI549Space\_desc-mean${suffix}.nii
			fi

			## task: vislocalizer
			suffix='_bold'
			task_name='vislocalizer'

			### raw
			touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}${suffix}.nii

			filename=${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}_events.tsv
			echo "onset\tduration\ttrial_type" > ${filename}
			echo "2\t15\tVisMot" >> ${filename}
			echo "25\t15\tVisStat" >> ${filename}

			### derivatives
			filename=${this_dir}/rp_sub-${subject}\_ses-${ses}\_task-${task_name}${suffix}.txt
			cp dummyData/rp.txt ${filename}
			touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}\_desc-confounds\_regressors.tsv

			func_prefix_list='a r u s6'
			for prefix in ${func_prefix_list}
			do
				touch ${this_dir}/${prefix}sub-${subject}\_ses-${ses}\_task-${task_name}${suffix}.nii
			done

			desc_label_list='preproc smth6'
			for desc in ${desc_label_list}
			do
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}\_space-individual\_desc-${desc}${suffix}.nii
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}\_space-IXI549Space\_desc-${desc}${suffix}.nii
			done

			if [ ${ses} = '01' ]; then
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}\_space-individual\_desc-mean${suffix}.nii
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_task-${task_name}\_space-IXI549Space\_desc-mean${suffix}.nii
			fi


			# FMAP
			this_dir=${preproc_dir}/sub-${subject}/ses-${ses}/fmap
			mkdir -p ${this_dir}

			fmap_suffix_list='_phasediff _magnitude1 _magnitude2'
			for suffix in ${fmap_suffix_list}
			do
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_run-1${suffix}.nii
				touch ${this_dir}/sub-${subject}\_ses-${ses}\_run-2${suffix}.nii
			done

			EchoTime1=0.006
			EchoTime2=0.00746
			template='{"EchoTime1":%f, "EchoTime2":%f, "IntendedFor":"%s"}'

			suffix='_bold'

			task_name='vismotion'
			IntendedFor=`echo ses-${ses}/func/sub-${subject}\_ses-${ses}\_task-${task_name}_run-1${suffix}.nii`
			json_string=$(printf "$template" "$EchoTime1" "$EchoTime2" "$IntendedFor")
			echo "$json_string" > ${this_dir}/sub-${subject}\_ses-${ses}\_run-2_phasediff.json

			task_name='vislocalizer'
			IntendedFor=`echo ses-${ses}/func/sub-${subject}\_ses-${ses}\_task-${task_name}${suffix}.nii`
			json_string=$(printf "$template" "$EchoTime1" "$EchoTime2" "$IntendedFor")
			echo "$json_string" > ${this_dir}/sub-${subject}\_ses-${ses}\_run-1_phasediff.json

		done


		# ANAT
		this_dir=${preproc_dir}/sub-${subject}/ses-01/anat
		mkdir -p ${this_dir}

		ses='01'
		suffix='_T1w'

		touch ${this_dir}/sub-${subject}\_ses-${ses}${suffix}.nii

		anat_prefix_list='m c1 c2 c3'
		for prefix in ${anat_prefix_list}
		do
			touch ${this_dir}/${prefix}sub-${subject}\_ses-${ses}${suffix}.nii
		done

		space='individual'

		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_desc-biascor${suffix}.nii
		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_desc-skullstripped${suffix}.nii
		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_desc-preproc${suffix}.nii
		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_label-brain\_mask.nii
		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_label-CSF\_probseg.nii
		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_label-GM\_probseg.nii
		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_label-WM\_probseg.nii

		space='IXI549Space'

		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_res-bold\_label-CSF\_probseg.nii
		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_res-bold\_label-GM\_probseg.nii
		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_res-bold\_label-WM\_probseg.nii
		touch ${this_dir}/sub-${subject}\_ses-${ses}\_space-${space}\_res-hi\_desc-preproc${suffix}.nii


		# STATS
		task_name='vismotion'
		this_dir=${stats_dir}/sub-${subject}/stats/task-${task_name}_space-MNI_FWHM-6
		mkdir -p ${this_dir}

		cp dummyData/SPM.mat ${this_dir}/SPM.mat

		touch ${this_dir}/mask.nii

		touch ${this_dir}/spmT_0001.nii
		touch ${this_dir}/spmT_0002.nii

		for i in `seq 1 4`
		do
			touch ${this_dir}/con_000${i}.nii
			touch ${this_dir}/s6con_000${i}.nii
		done

done;
