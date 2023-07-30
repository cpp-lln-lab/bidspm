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
	cd inputs/ds000001 && datalad get sub-0[123] -J 3
	cd inputs/ds000001-fmriprep && datalad get sub-0[123]/func/*tsv -J 12
	cd inputs/ds000001-fmriprep && datalad get sub-0[123]/func/*json -J 12
	cd inputs/ds000001-fmriprep && datalad get sub-0[123]/func/*MNI*desc-*bold.nii.gz -J 12
	cd inputs/ds000001-fmriprep && datalad get sub-0[123]/anat/*MNI*desc-preproc*.nii.gz -J 12


data_ds000114:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds000114
	cd inputs/ds000114 && datalad get sub-0[12] -J 2

data_ds001168:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds001168
	cd inputs/ds001168 && datalad get ds001168/sub-0[12] -J 2

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
