.PHONY: clean data data_ds000001

data_ds000114:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds000114
	cd inputs && datalad install ///openneuro-derivatives/ds000114-fmriprep
	cd inputs/ds000114-fmriprep && datalad get sub-*/anat/*MNI152NLin2009cAsym*desc-preproc*.nii.gz -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-*/ses-*/func/*tsv -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-*/ses-*/func/*json -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-*/ses-*/func/*linebisection*MNI152NLin2009cAsym*_mask.nii.gz -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-*/ses-*/func/*linebisection*MNI152NLin2009cAsym*desc-preproc*bold.nii.gz -J 12
