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
	rm -rf outputs
	rm -rf cfg

data:
	mkdir inputs
	cd inputs && datalad install ///openneuro/ds000001
	cd inputs && datalad install ///openneuro/ds000114
	cd inputs && datalad install ///openneuro/ds000168
	datalad get inputs/ds000*/sub-0[12]

# all: $(roi)

# $(preproc): moae_01_preproc.m
# 	$(MATLAB) $(ARG) -r "run('moae_01_preproc.m');exit;"

# $(stats): $(preproc)
# 	$(MATLAB) $(ARG) -r "run('moae_02_stats.m');exit;"

# $(roi): $(stats) moae_03_create_roi_extract_data.m
# 	$(MATLAB) $(ARG) -r "run('moae_03_create_roi_extract_data.m');exit;"
