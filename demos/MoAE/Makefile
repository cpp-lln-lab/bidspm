# the path to matlab on your machine might need to be changed
# for this to work on your machine
MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

OCTFLAGS = --no-gui --no-window-system --silent

preproc  = outputs/derivatives/cpp_spm-preproc/sub-%/func/sub-%_task-%_space-%_desc-smth%_bold.nii
stats    = outputs/derivatives/cpp_spm-stats/sub-%/stats/task-%_space-MNI%/con_%.nii
roi      = outputs/derivatives/cpp_spm-roi/sub-%/roi/sub-%_space-MNI_desc-%_mask.nii

clean:
	rm -rf inputs
	rm -rf outputs/derivatives
	rm -rf cfg
	rm -f MoAEpilot.zip

inputs/raw:
	mkdir inputs/ -p
	octave $(OCTFLAGS) --eval "run('download_moae_ds.m');exit;"

# cd inputs && datalad install https://gin.g-node.org/RemiGau/spm_moae_fmriprep.git
# cd inputs && datalad install git@gin.g-node.org:/RemiGau/spm_moae_fmriprep.git
# git@gin.g-node.org:/SPM_datasets/spm_moae_fmriprep.git
inputs/fmriprep:
	datalad install --source git@gin.g-node.org:/SPM_datasets/spm_moae_fmriprep.git \
					inputs/fmriprep
	cd inputs/fmriprep && datalad get *.json \
										*/*/*tsv \
										*/*/*json \
										*/*/*desc-preproc*.nii.gz \
										*/*/*desc-brain*.nii.gz
all: $(roi)

$(preproc): moae_01_preproc.m
	$(MATLAB) $(ARG) -r "run('moae_01_preproc.m');exit;"

$(stats): $(preproc)
	$(MATLAB) $(ARG) -r "run('moae_02_stats.m');exit;"

$(roi): $(stats) moae_03_create_roi_extract_data.m
	$(MATLAB) $(ARG) -r "run('moae_03_create_roi_extract_data.m');exit;"

# Octave related recipes
octave_all: octave_roi

octave_preproc: moae_01_preproc.m
	octave $(OCTFLAGS) --eval "run('moae_01_preproc.m');exit;"

octave_stats: moae_02_stats.m
	octave $(OCTFLAGS) --eval "run('moae_02_stats.m');exit;"

octave_roi: moae_03_create_roi_extract_data.m
	octave $(OCTFLAGS) --eval "run('moae_03_create_roi_extract_data.m');exit;"
