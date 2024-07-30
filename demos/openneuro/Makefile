.PHONY: clean data data_ds000001

# the path to matlab on your machine might need to be changed
# for this to work on your machine
MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

OCTFLAGS = --no-gui --no-window-system --silent

clean:
	rm -rf inputs/ds*
	rm -rf outputs/derivatives
	rm -rf cfg

data: data_ds000001 data_ds000114 data_ds001168

data_ds000001:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds000001
	cd inputs && datalad install ///openneuro-derivatives/ds000001-fmriprep
	cd inputs/ds000001 && datalad get sub-0[1-5] -J 3
	cd inputs/ds000001-fmriprep && datalad get sub-0[1-5]/func/*tsv -J 12
	cd inputs/ds000001-fmriprep && datalad get sub-0[1-5]/func/*json -J 12
	cd inputs/ds000001-fmriprep && datalad get sub-0[1-5]/anat/*MNI*desc-preproc*.nii.gz -J 12
	cd inputs/ds000001-fmriprep && datalad get sub-0[1-5]/func/*MNI*desc-preproc*.nii.gz -J 12
	cd inputs/ds000001-fmriprep && datalad get sub-0[1-3]/func/*MNI*desc-*bold.nii.gz -J 12

data_ds000114_raw:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds000114
	cd inputs/ds000114 && datalad get sub-0[1-2]/ses-*/anat/*T1w*.nii.gz -J 12
	cd inputs/ds000114 && datalad get sub-0[1-2]/ses-*/func/*linebisection* -J 12

data_ds000114:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds000114
	cd inputs && datalad install ///openneuro-derivatives/ds000114-fmriprep
	cd inputs/ds000114-fmriprep && datalad get sub-0[1-2]/anat/*MNI*desc-preproc*.nii.gz -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-0[1-2]/ses-*/func/*tsv -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-0[1-2]/ses-*/func/*json -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-0[1-2]/ses-*/func/*MNI*_mask.nii.gz -J 12
	cd inputs/ds000114-fmriprep && datalad get sub-0[1-2]/ses-*/func/*MNI*desc-preproc*bold.nii.gz -J 12

data_ds000224:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds000224
	cd inputs && datalad install https://github.com/OpenNeuroDerivatives/ds000224-fmriprep
	cd inputs/ds000224-fmriprep && datalad get sub-MSC0[1-2]/anat/*MNI*desc-preproc*.nii.gz -J 12
	cd inputs/ds000224-fmriprep && datalad get sub-MSC0[1-2]/ses-*/func/*glasslexical*tsv -J 12
	cd inputs/ds000224-fmriprep && datalad get sub-MSC0[1-2]/ses-*/func/*glasslexical*json -J 12
	cd inputs/ds000224-fmriprep && datalad get sub-MSC0[1-2]/ses-*/func/*glasslexical*MNI*_mask.nii.gz -J 12
	cd inputs/ds000224-fmriprep && datalad get sub-MSC0[1-2]/ses-*/func/*glasslexical*MNI*desc-preproc*bold.nii.gz -J 12

data_ds001168:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds001168
	cd inputs/ds001168 && datalad get sub-0[12]/ses*/anat/*T1w* -J 2
	cd inputs/ds001168 && datalad get sub-0[12]/ses*/func/*fullbrain*bold* -J 2

data_ds001734:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds001734
	cd inputs && datalad install ///openneuro-derivatives/ds001734-fmriprep
	cd inputs/ds001734-fmriprep && datalad get sub-00[1]/anat/*MNI152NLin2009cAsym*mask.nii.gz -J 12
	cd inputs/ds001734-fmriprep && datalad get sub-00[1]/anat/*MNI152NLin2009cAsym*T1w.nii.gz -J 12
	cd inputs/ds001734-fmriprep && datalad get sub-00[1]/func/*tsv -J 12
	cd inputs/ds001734-fmriprep && datalad get sub-00[1]/func/*json -J 12
	cd inputs/ds001734-fmriprep && datalad get sub-00[1]/func/*MNI152NLin2009cAsym*desc-preproc*bold.nii.gz -J 12

data_ds002799:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds002799
	datalad get -d inputs/ds002799 inputs/ds002799/derivatives/fmriprep/sub-292/*/func/*MNI152NLin2009cAsym*
	datalad get -d inputs/ds002799 inputs/ds002799/derivatives/fmriprep/sub-292/*/func/*tsv
	datalad get -d inputs/ds002799 inputs/ds002799/derivatives/fmriprep/sub-30[27]/*/func/*MNI152NLin2009cAsym* -J 2
	datalad get -d inputs/ds002799 inputs/ds002799/derivatives/fmriprep/sub-30[27]/*/func/*tsv -J 2

data_ds003397:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds003397
	cd inputs && datalad install https://github.com/OpenNeuroDerivatives/ds003397-fmriprep
	cd inputs/ds003397-fmriprep && datalad get sub-[01][1267]/anat/*MNI152NLin2009cAsym*T1w.nii.gz -J 12
	cd inputs/ds003397-fmriprep && datalad get sub-[01][1267]/anat/*mask*.nii.gz -J 12
	cd inputs/ds003397-fmriprep && datalad get sub-[01][1267]/func/*time*tsv -J 12
	cd inputs/ds003397-fmriprep && datalad get sub-[01][1267]/func/*json -J 12
	cd inputs/ds003397-fmriprep && datalad get sub-[01][1267]/func/*MNI152NLin2009cAsym*desc-preproc*bold.nii.gz -J 12
