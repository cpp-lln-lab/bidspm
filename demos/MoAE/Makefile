# the path to matlab on your machine might need to be changed
# for this to work on your machine
MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

OCTFLAGS = --no-gui --no-window-system --silent

preproc  = outputs/derivatives/bidspm-preproc/sub-%/func/sub-%_task-%_space-%_desc-smth%_bold.nii
stats    = outputs/derivatives/bidspm-stats/sub-%/stats/task-%_space-IXI549Space%/con_%.nii
roi      = outputs/derivatives/bidspm-roi/sub-%/roi/sub-%_space-MNI_desc-%_mask.nii

clean:
	rm -rf inputs
	rm -rf outputs/derivatives
	rm -rf cfg
	rm -f MoAEpilot.zip

inputs/raw:
	mkdir inputs/ -p
	octave $(OCTFLAGS) --eval "run('download_moae_ds.m');exit;"

inputs/fmriprep:
	datalad install -s git@gin.g-node.org:/SPM_datasets/spm_moae_fmriprep.git \
					inputs/fmriprep
	cd inputs/fmriprep && datalad get *.json \
										*/*/*tsv \
										*/*/*json \
										*/*/*desc-preproc*.nii.gz \
										*/*/*desc-brain*.nii.gz
all: $(roi)

$(stats):
	$(MATLAB) $(ARG) -r "run('moae_01_bids_app.m');exit;"

$(roi): $(stats) moae_03_create_roi_extract_data.m
	$(MATLAB) $(ARG) -r "run('moae_02_create_roi_extract_data.m');exit;"

# Octave related recipes
octave_all: octave_roi

octave_stats: moae_01_bids_app.m
	octave $(OCTFLAGS) --eval "run('moae_01_bids_app.m');exit;"

octave_roi: moae_03_create_roi_extract_data.m
	octave $(OCTFLAGS) --eval "run('moae_02_create_roi_extract_data.m');exit;"
