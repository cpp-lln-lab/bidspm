.PHONY: clean data data_ds000001

clean:
	rm -rf inputs
	mkdir inputs
	touch inputs/.gitkeep

data_install:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds000114
	cd inputs && datalad install ///openneuro-derivatives/ds000114-fmriprep
	cd inputs/ds000114-fmriprep && datalad get sub-*/anat/*MNI152NLin2009cAsym*desc-preproc*.nii.gz -J 12

data_ds000114: data_install
	cd inputs/ds000114-fmriprep && datalad get sub-*/anat/*MNI152NLin2009cAsym*desc-preproc*.nii.gz -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-*/ses-*/func/*tsv -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-*/ses-*/func/*json -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-*/ses-*/func/*overtverbgeneration*MNI152NLin2009cAsym*_mask.nii.gz -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-*/ses-*/func/*overtverbgeneration*MNI152NLin2009cAsym*desc-preproc*bold.nii.gz -J 12

data_ds000114_testing: data_install
	cd inputs/ds000114-fmriprep && datalad get sub-0[12]/anat/*MNI152NLin2009cAsym*desc-preproc*.nii.gz -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-0[12]/ses-*/func/*tsv -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-0[12]/ses-*/func/*json -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-0[12]/ses-*/func/*overtverbgeneration*MNI152NLin2009cAsym*_mask.nii.gz -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-0[12]/ses-*/func/*overtverbgeneration*MNI152NLin2009cAsym*desc-preproc*bold.nii.gz -J 12
