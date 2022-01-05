# change the following line to point to where MATLAB is on your system
# MATLAB = /Applications/MATLAB_R2017b.app/bin/matlab
MATLAB = /usr/local/MATLAB/R2017a/bin/matlab

ARG    = -nodisplay -nosplash -nodesktop

.PHONY: all clean clean_moco
clean:
	rm -rf outputs

clean_moco:
	rm -f outputs/derivatives/moco*.nii
	rm -f outputs/derivatives/rp_*.txt
	rm -f outputs/derivatives/meanrun*.nii
	rm -f outputs/derivatives/run*.mat
	rm -f outputs/derivatives/realign_batch.mat

all: outputs/derivatives/run1_motion.ps

prepare: prepare_derivative.sh
	bash prepare_derivative.sh

moco: prepare motion_correction.m
	$(MATLAB) $(ARG) -r "motion_correction"

coregister: moco coregister.m
	$(MATLAB) $(ARG) -r "coregister"

epi_T1:
	bash create_T1_in_epi_space.sh



plot: gnuplot_moco.txt
	gnuplot "gnuplot_moco.txt"

glm:
	$(MATLAB) $(ARG) -r "convert_events_tsv"