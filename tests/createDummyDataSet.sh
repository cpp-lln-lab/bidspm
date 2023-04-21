#!/bin/bash

# small bash script to create a dummy BIDS data set

# defines where the BIDS data set will be created
start_dir=$(pwd) # relative to starting directory
raw_dir=${start_dir}/data/bidspm-raw
preproc_dir=${start_dir}/data/derivatives/bidspm-preproc
stats_dir=${start_dir}/data/derivatives/bidspm-stats
roi_dir=${start_dir}/data/derivatives/bidspm-roi

subject_list='ctrl01 blind01 01'
session_list='01 02'
roi_list='V1 A1'
hemispheres='L R'

create_raw_func_vismotion() {

	target_dir=$1
	subject=$2
	ses=$3

	suffix='_bold'
	task_name='vismotion'

	this_dir=${target_dir}/sub-${subject}/ses-${ses}/func

	basename=sub-${subject}_ses-${ses}_task-${task_name}

	mkdir -p "${this_dir}"

	for run in $(seq 1 2); do
		filename=${this_dir}/${basename}_run-${run}${suffix}.nii
		touch "${filename}"
	done

	filename="${this_dir}/${basename}_run-1_events.tsv"
	echo "onset\tduration\ttrial_type" >"${filename}"
	echo "2\t2\tVisMot" >>"${filename}"
	echo "4\t2\tVisStat" >>"${filename}"

	filename="${this_dir}/${basename}_run-2_events.tsv"
	echo "onset\tduration\ttrial_type" >"${filename}"
	echo "3\t2\tVisStat" >>"${filename}"
	echo "6\t2\tVisMot" >>"${filename}"

	touch "${this_dir}/${basename}_acq-1p60mm_run-1${suffix}.nii"

	filename="${this_dir}/${basename}_acq-1p60mm_run-1_events.tsv"
	echo "onset\tduration\ttrial_type" >"${filename}"
	echo "4\t2\tVisMot" >>"${filename}"
	echo "8\t2\tVisStat" >>"${filename}"

	touch "${this_dir}/${basename}_acq-1p60mm_dir-PA_run-1${suffix}.nii"

	filename="${this_dir}/${basename}_acq-1p60mm_run-2_events.tsv"
	echo "onset\tduration\ttrial_type" >"${filename}"
	echo "4\t2\tVisMot" >>"${filename}"
	echo "8\t2\tVisStat" >>"${filename}"

	touch "${this_dir}/${basename}_acq-1p60mm_dir-PA_run-2${suffix}.nii"
}

create_raw_func_vislocalizer() {

	target_dir=$1
	subject=$2
	ses=$3

	suffix='_bold'
	task_name='vislocalizer'

	this_dir=${target_dir}/sub-${subject}/ses-${ses}/func

	mkdir -p ${this_dir}

	filename=${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}${suffix}.nii
	touch "${filename}"

	filename=${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_events.tsv
	echo "onset\tduration\ttrial_type" >"${filename}"
	echo "2\t15\tVisMot" >>"${filename}"
	echo "25\t15\tVisStat" >>"${filename}"

}

create_raw_func_rest() {

	target_dir=$1
	subject=$2
	ses=$3

	suffix='_bold'
	task_name='rest'

	this_dir=${target_dir}/sub-${subject}/ses-${ses}/func

	mkdir -p "${this_dir}"

	touch "${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}${suffix}.nii"

}

create_raw_fmap() {

	target_dir=$1
	subject=$2
	ses=$3

	this_dir=${target_dir}/sub-${subject}/ses-${ses}/fmap

	mkdir -p "${this_dir}"

	fmap_suffix_list='_phasediff _magnitude1 _magnitude2'
	for suffix in ${fmap_suffix_list}; do
		touch "${this_dir}/sub-${subject}_ses-${ses}_run-1${suffix}.nii"
		touch "${this_dir}/sub-${subject}_ses-${ses}_run-2${suffix}.nii"
	done

	EchoTime1=0.006
	EchoTime2=0.00746
	template='{"EchoTime1":%f, "EchoTime2":%f, "IntendedFor":"%s"}'

	suffix='_bold'

	task_name='vislocalizer'
	IntendedFor=$(echo ses-${ses}/func/sub-${subject}_ses-${ses}_task-${task_name}${suffix}.nii)
	json_string=$(printf "$template" "$EchoTime1" "$EchoTime2" "$IntendedFor")
	echo "$json_string" >${this_dir}/sub-${subject}_ses-${ses}_run-1_phasediff.json

	task_name='vismotion'
	IntendedFor=$(echo ses-${ses}/func/sub-${subject}_ses-${ses}_task-${task_name}_run-1${suffix}.nii)
	json_string=$(printf "$template" "$EchoTime1" "$EchoTime2" "$IntendedFor")
	echo "$json_string" >"${this_dir}/sub-${subject}_ses-${ses}_run-2_phasediff.json"

}

create_raw_anat() {

	target_dir=$1
	subject=$2

	ses='01'
	suffix='_T1w'

	this_dir=${target_dir}/sub-${subject}/ses-01/anat
	mkdir -p ${this_dir}

	touch "${this_dir}/sub-${subject}_ses-${ses}${suffix}.nii"

	# MP2RAGE
	touch "${this_dir}/sub-${subject}_ses-${ses}_UNIT1.nii"
	touch "${this_dir}/sub-${subject}_ses-${ses}_inv-1_MP2RAGE.nii"
	touch "${this_dir}/sub-${subject}_ses-${ses}_inv-2_MP2RAGE.nii"

	template='{"MagneticFieldStrength":%f, "RepetitionTimePreparation":%f, "InversionTime":%f, "FlipAngle":%f, "FatSat":"%s", "EchoSpacing":%f, "PartialFourierInSlice":%f}'

	FlipAngle=4
	MagneticFieldStrength=7
	RepetitionTimePreparation=4.3
	InversionTime=1
	Fatsat="yes"
	EchoSpacing=0.0072
	PartialFourierInSlice=0.75

	json_string=$(printf "$template" "$MagneticFieldStrength" "$RepetitionTimePreparation" "$InversionTime" "$FlipAngle" "$Fatsat" "$EchoSpacing" "$PartialFourierInSlice")
	echo "$json_string" >${this_dir}/sub-${subject}_ses-${ses}_inv-1_MP2RAGE.json

	InversionTime=3.2

	json_string=$(printf "$template" "$MagneticFieldStrength" "$RepetitionTimePreparation" "$InversionTime" "$FlipAngle" "$Fatsat" "$EchoSpacing" "$PartialFourierInSlice")
	echo "$json_string" >${this_dir}/sub-${subject}_ses-${ses}_inv-2_MP2RAGE.json

}

# RAW DATASET
for subject in ${subject_list}; do
	for ses in ${session_list}; do
		create_raw_func_vismotion ${raw_dir} ${subject} ${ses}
		create_raw_func_vislocalizer ${raw_dir} ${subject} ${ses}
		create_raw_fmap ${raw_dir} ${subject} ${ses}
	done

	create_raw_func_rest ${raw_dir} ${subject} '02'
	create_raw_anat ${raw_dir} ${subject}
done

# ROIs
mkdir -p ${roi_dir}/group
for roi in ${roi_list}; do
	touch "${roi_dir}/group/${roi}_mask.nii"
done

for subject in ${subject_list}; do
	this_dir=${roi_dir}/sub-${subject}/roi
	mkdir -p "${this_dir}"
	for roi in ${roi_list}; do
		for hemi in ${hemispheres}; do
			touch "${this_dir}/sub-${subject}_hemi-${hemi}_space-individual_label-${roi}_mask.nii"
		done
	done
done

# DERIVATIVES DATASET
for subject in ${subject_list}; do

	for ses in ${session_list}; do

		# FUNC
		create_raw_func_vismotion ${preproc_dir} ${subject} ${ses}
		create_raw_func_vislocalizer ${preproc_dir} ${subject} ${ses}
		create_raw_fmap ${preproc_dir} ${subject} ${ses}

		this_dir=${preproc_dir}/sub-${subject}/ses-${ses}/func

		## task: vismotion
		suffix='_bold'
		task_name='vismotion'

		### derivatives
		desc_label_list='preproc mean smth6'
		for acq in $(seq 1 2); do

			acq_entity=""
			if [ ${acq} = 2 ]; then
				acq_entity="_acq-1p60mm"
			fi

			basename=sub-${subject}_ses-${ses}_task-${task_name}${acq_entity}

			for run in $(seq 1 2); do

				filename=${this_dir}/rp_${basename}_run-${run}${suffix}.txt
				cp data/tsv_files/rp.txt "${filename}"
				cp data/tsv_files/rp.tsv ${this_dir}/${basename}_run-${run}_desc-confounds_regressors.tsv

				for desc in ${desc_label_list}; do
					touch ${this_dir}/${basename}_run-${run}_space-individual_desc-${desc}${suffix}.nii
					touch ${this_dir}/${basename}_run-${run}_space-IXI549Space_desc-${desc}${suffix}.nii
				done
				touch ${this_dir}/${basename}_run-${run}_space-individual_desc-stc${suffix}.nii

				touch ${this_dir}/${basename}_run-${run}_space-IXI549Space_label-brain_mask.nii

			done

			if [ ${ses} = '01' ]; then
				touch ${this_dir}/${basename}_space-individual_desc-mean${suffix}.nii
				touch ${this_dir}/${basename}_space-IXI549Space_desc-mean${suffix}.nii

				touch ${this_dir}/mean_${basename}${suffix}.nii
			fi

		done

		## task: vislocalizer
		suffix='_bold'
		task_name='vislocalizer'

		### derivatives
		filename=${this_dir}/rp_sub-${subject}_ses-${ses}_task-${task_name}${suffix}.txt
		cp data/tsv_files/rp.txt "${filename}"
		cp data/tsv_files/rp.tsv ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_desc-confounds_regressors.tsv

		desc_label_list='preproc smth6'
		for desc in ${desc_label_list}; do
			touch ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_space-individual_desc-${desc}${suffix}.nii
			touch ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_space-IXI549Space_desc-${desc}${suffix}.nii
			touch ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_space-IXI549Space_label-brain_mask.nii
		done
		touch ${this_dir}/mean_sub-${subject}_ses-${ses}_task-${task_name}${suffix}.nii

		if [ ${ses} = '01' ]; then
			touch ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_space-individual_desc-mean${suffix}.nii
			touch ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_space-IXI549Space_desc-mean${suffix}.nii
		fi

	done

	## task: rest
	ses='02'
	suffix='_bold'
	task_name='rest'

	### raw & derivatives
	create_raw_func_rest ${preproc_dir} ${subject} '02'
	touch ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_space-individual_desc-preproc${suffix}.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_space-individual_label-brain_mask.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_space-IXI549Space_desc-preproc${suffix}.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_task-${task_name}_space-IXI549Space_label-brain_mask.nii

	# ANAT
	create_raw_anat ${preproc_dir} ${subject}

	ses='01'
	suffix='_T1w'

	## derivatives
	this_dir=${preproc_dir}/sub-${subject}/ses-01/anat

	anat_prefix_list='m c1 c2 c3'
	for prefix in ${anat_prefix_list}; do
		touch ${this_dir}/${prefix}sub-${subject}_ses-${ses}${suffix}.nii
	done



	space='individual'

	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_desc-biascor${suffix}.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_desc-skullstripped${suffix}.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_desc-preproc${suffix}.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_label-brain_mask.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_label-CSF_probseg.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_label-GM_probseg.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_label-WM_probseg.nii

	space='IXI549Space'

	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_res-bold_label-CSF_probseg.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_res-bold_label-GM_probseg.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_res-bold_label-WM_probseg.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_res-hi_desc-preproc${suffix}.nii
	touch ${this_dir}/sub-${subject}_ses-${ses}_space-${space}_desc-brain_mask.nii

	# deformation fields
	touch ${this_dir}/sub-${subject}_ses-${ses}_from-IXI549Space_to-T1w_mode-image_xfm.nii

	# STATS
	task_list='vismotion vislocalizer'
	for task in ${task_list}; do

		this_dir=${stats_dir}/sub-${subject}/task-${task}_space-IXI549Space_FWHM-6
		mkdir -p ${this_dir}

		cp data/mat_files/SPM.mat ${this_dir}/SPM.mat

		touch ${this_dir}/mask.nii

		for i in $(seq 1 9); do
			touch ${this_dir}/beta_000${i}.nii
		done

		for i in $(seq 1 4); do
			touch ${this_dir}/spmT_000${i}.nii
			touch ${this_dir}/con_000${i}.nii
			touch ${this_dir}/s6con_000${i}.nii
		done
	done

	# different model for model comparison
	task_list='vismotion vislocalizer'
	for task in ${task_list}; do
		this_dir=${stats_dir}/sub-${subject}/task-${task}_space-IXI549Space_FWHM-6_node-globalSignal
		mkdir -p ${this_dir}

		cp data/mat_files/SPM.mat ${this_dir}/SPM.mat

		touch ${this_dir}/mask.nii

		for i in $(seq 1 10); do
			touch ${this_dir}/beta_000${i}.nii
		done

		for i in $(seq 1 2); do
			touch ${this_dir}/spmT_000${i}.nii
			touch ${this_dir}/con_000${i}.nii
		done
	done

done
