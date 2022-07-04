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
	datalad -d inputs/ds000001 get inputs/ds000001/sub-0[12]

data_ds000114:
	mkdir -p inputs
	cd inputs && datalad install ///openneuro/ds000114
	datalad -d inputs/ds000114 get inputs/ds000114/sub-0[12]

data_ds001168:
	datalad install ///openneuro/ds001168 inputs/ds001168
	datalad -d inputs/ds001168 get inputs/ds001168/sub-0[12]

data_ds002799:
	datalad install ///openneuro/ds002799 inputs/ds002799
	cd inputs/ds002799/derivatives/fmriprep
	datalad -d get sub-292/*/func/*MNI152NLin2009cAsym*
	datalad get sub-292/*/func/*tsv
	datalad get sub-30[27]/*/func/*MNI152NLin2009cAsym*
	datalad get sub-30[27]/*/func/*tsv
