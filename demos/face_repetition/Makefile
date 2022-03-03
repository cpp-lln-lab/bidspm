# the path to matlab on your machine might need to be changed
# for this to work on your machine
MATLAB = /usr/local/MATLAB/R2017a/bin/matlab
ARG    = -nodisplay -nosplash -nodesktop

OCTFLAGS = --no-gui --no-window-system --silent

preproc    = outputs/derivatives/cpp_spm-preproc/sub-%/func/sub-%_task-%_space-%_desc-smth%_bold.nii
stats      = outputs/derivatives/cpp_spm-stats/sub-%/stats/task-%_space-MNI%/con_%.nii
roi        = outputs/derivatives/cpp_spm-roi/sub-%/roi/sub-%_space-MNI_desc-%_mask.nii
anat       = outputs/derivatives/cpp_spm-anat-preproc
resolution = outputs/derivatives/cpp_spm-res%

clean:
	rm -rf inputs
	rm -rf outputs/derivatives outputs/raw
	rm -rf cfg
	rm face_rep.zip

all: $(roi)

$(preproc): face_rep_01_preproc_func.m
	$(MATLAB) $(ARG) -r "run('face_rep_01_preproc_func.m');exit;"

$(stats): $(preproc) face_rep_02_stats.m
	$(MATLAB) $(ARG) -r "run('face_rep_02_stats.m');exit;"

$(roi): $(stats) face_rep_03_roi_analysis.m
	$(MATLAB) $(ARG) -r "run('face_rep_03_roi_analysis.m');exit;"

$(anat): face_rep_anat.m
	$(MATLAB) $(ARG) -r "run('face_rep_anat.m');exit;"

$(resolution): face_rep_resolution.m
	$(MATLAB) $(ARG) -r "run('face_rep_resolution.m');exit;"

# Octave related recipes
octave_all: octave_roi

octave_prepoc: face_rep_01_preproc_func.m
	octave $(OCTFLAGS) --eval "run('face_rep_01_preproc_func.m');exit;"

octave_stats: octave_prepoc face_rep_02_stats.m
	octave $(OCTFLAGS) --eval "run('face_rep_02_stats.m');exit;"

octave_roi: octave_stats face_rep_03_roi_analysis.m
	octave $(OCTFLAGS) --eval "run('face_rep_03_roi_analysis.m');exit;"

