#!/bin/bash


# Upsample
delta_x=$($HOME/abin/3dinfo -di sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w.nii)
delta_y=$($HOME/abin/3dinfo -dj sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w.nii)
delta_z=$($HOME/abin/3dinfo -dk sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w.nii)



sdelta_x=$(echo "((sqrt($delta_x * $delta_x) / 5))"|bc -l)
sdelta_y=$(echo "((sqrt($delta_y * $delta_y) / 1))"|bc -l)
sdelta_z=$(echo "((sqrt($delta_z * $delta_z) / 5))"|bc -l)

# here I only upscale in 2 dimensions.
#3dresample -dxyz $sdelta_x $sdelta_y $sdelta_z -rmode NN -overwrite -prefix scaled_$1 -input $1
$HOME/abin/3dresample \
    -dxyz $sdelta_x $sdelta_y $sdelta_z \
    -rmode Cu \
    -overwrite \
    -prefix scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w.nii \
    -input sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w.nii

$HOME/abin/3dresample \
     -dxyz $sdelta_x $sdelta_y $sdelta_z \
     -rmode Cu \
     -overwrite \
     -prefix scaled_vaso_con_0001_auditory.nii \
     -input vaso_con_0001_auditory.nii

$HOME/abin/3dresample \
     -dxyz $sdelta_x $sdelta_y $sdelta_z \
     -rmode Cu \
     -overwrite \
     -prefix scaled_vaso_con_0002_visual.nii \
     -input vaso_con_0002_visual.nii

$HOME/abin/3dresample \
     -dxyz $sdelta_x $sdelta_y $sdelta_z \
     -rmode Cu \
     -overwrite \
     -prefix scaled_vaso_con_0003_bimodal.nii \
     -input vaso_con_0003_bimodal.nii

$HOME/abin/3dresample \
     -dxyz $sdelta_x $sdelta_y $sdelta_z \
     -rmode Cu \
     -overwrite \
     -prefix scaled_bold_con_0001_auditory.nii \
     -input bold_con_0001_auditory.nii

$HOME/abin/3dresample \
     -dxyz $sdelta_x $sdelta_y $sdelta_z \
     -rmode Cu \
     -overwrite \
     -prefix scaled_bold_con_0002_visual.nii \
     -input bold_con_0002_visual.nii

$HOME/abin/3dresample \
     -dxyz $sdelta_x $sdelta_y $sdelta_z \
     -rmode Cu \
     -overwrite \
     -prefix scaled_bold_con_0003_bimodal.nii \
     -input bold_con_0003_bimodal.nii

#

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii \
    -1DRformat \
    -quiet \
    -nzmean moved_scaled_vaso_con_0001_auditory.nii.gz > three_layer_vaso_con_0001_auditory.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii \
    -1DRformat \
    -quiet \
    -sigma moved_scaled_vaso_con_0001_auditory.nii.gz >> three_layer_vaso_con_0001_auditory.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii \
    -1DRformat \
    -quiet \
    -nzvoxels moved_scaled_vaso_con_0001_auditory.nii.gz >> three_layer_vaso_con_0001_auditory.dat



#

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii \
    -1DRformat \
    -quiet \
    -nzmean moved_scaled_vaso_con_0002_visual.nii.gz > three_layer_vaso_con_0002_visual.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii \
    -1DRformat \
    -quiet \
    -sigma moved_scaled_vaso_con_0002_visual.nii.gz >> three_layer_vaso_con_0002_visual.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii \
    -1DRformat \
    -quiet \
    -nzvoxels moved_scaled_vaso_con_0002_visual.nii.gz >> three_layer_vaso_con_0002_visual.dat

#

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii \
    -1DRformat \
    -quiet \
    -nzmean moved_scaled_vaso_con_0003_bimodal.nii.gz > three_layer_vaso_con_0003_bimodal.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii \
    -1DRformat \
    -quiet \
    -sigma moved_scaled_vaso_con_0003_bimodal.nii.gz >> three_layer_vaso_con_0003_bimodal.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii \
    -1DRformat \
    -quiet \
    -nzvoxels moved_scaled_vaso_con_0003_bimodal.nii.gz >> three_layer_vaso_con_0003_bimodal.dat

################################################################################################################################


$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_11layers.nii \
    -1DRformat \
    -quiet \
    -nzmean moved_scaled_vaso_con_0001_auditory.nii > eleven_layer_vaso_con_0001_auditory.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_11layers.nii \
    -1DRformat \
    -quiet \
    -sigma moved_scaled_vaso_con_0001_auditory.nii >> eleven_layer_vaso_con_0001_auditory.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_11layers.nii \
    -1DRformat \
    -quiet \
    -nzvoxels moved_scaled_vaso_con_0001_auditory.nii >> eleven_layer_vaso_con_0001_auditory.dat

# WRD=$(head -n 1 eleven_layer_vaso_con_0001_auditory.dat|wc -w); for((i=2;i<=$WRD;i=i+2)); do awk '{print $'$i'}' eleven_layer_vaso_con_0001_auditory.dat| tr '\n' ' ';echo; done > eleven_layer_vaso_con_0001_auditory.dat

#

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_11layers.nii \
    -1DRformat \
    -quiet \
    -nzmean moved_scaled_vaso_con_0002_visual.nii.gz > eleven_layer_vaso_con_0002_visual.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_11layers.nii \
    -1DRformat \
    -quiet \
    -sigma moved_scaled_vaso_con_0002_visual.nii.gz >> eleven_layer_vaso_con_0002_visual.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_11layers.nii \
    -1DRformat \
    -quiet \
    -nzvoxels moved_scaled_vaso_con_0002_visual.nii.gz >> eleven_layer_vaso_con_0002_visual.dat

# WRD=$(head -n 1 eleven_layer_vaso_con_0002_visual.dat|wc -w); for((i=2;i<=$WRD;i=i+2)); do awk '{print $'$i'}' eleven_layer_vaso_con_0002_visual.dat| tr '\n' ' ';echo; done > eleven_layer_vaso_con_0002_visual.dat

#

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_11layers.nii \
    -1DRformat \
    -quiet \
    -nzmean moved_scaled_vaso_con_0003_bimodal.nii.gz > eleven_layer_vaso_con_0003_bimodal.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_11layers.nii \
    -1DRformat \
    -quiet \
    -sigma moved_scaled_vaso_con_0003_bimodal.nii.gz >> eleven_layer_vaso_con_0003_bimodal.dat

$HOME/abin/3dROIstats \
    -mask moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_11layers.nii \
    -1DRformat \
    -quiet \
    -nzvoxels moved_scaled_vaso_con_0003_bimodal.nii.gz >> eleven_layer_vaso_con_0003_bimodal.dat

# WRD=$(head -n 1 eleven_layer_vaso_con_0003_bimodal.dat|wc -w); for((i=2;i<=$WRD;i=i+2)); do awk '{print $'$i'}' eleven_layer_vaso_con_0003_bimodal.dat| tr '\n' ' ';echo; done > eleven_layer_vaso_con_0003_bimodal.dat

################################################################################################################################

#extractiong profiles for VASO
#get mean value, STDEV, and number of voxels
3dROIstats -mask layers.nii -1DRformat -quiet -nzmean scaled_VASO.nii > layer_t.dat
3dROIstats -mask layers.nii -1DRformat -quiet -sigma scaled_VASO.nii >> layer_t.dat
3dROIstats -mask layers.nii -1DRformat -quiet -nzvoxels scaled_VASO.nii >> layer_t.dat
#format file to be in columns, so gnuplot can read it.
WRD=$(head -n 1 layer_t.dat|wc -w); for((i=2;i<=$WRD;i=i+2)); do awk '{print $'$i'}' layer_t.dat| tr '\n' ' ';echo; done > layer.dat

echo "ciao"

1dplot -sepscl layer.dat
mv layer.dat layer_VASO.dat

#extractiong profiles for BOLD
#get mean value, STDEV, and number of voxels
3dROIstats -mask layers.nii -1DRformat -quiet -nzmean scaled_BOLD.nii > layer_t.dat
3dROIstats -mask layers.nii -1DRformat -quiet -sigma scaled_BOLD.nii >> layer_t.dat
3dROIstats -mask layers.nii -1DRformat -quiet -nzvoxels scaled_BOLD.nii >> layer_t.dat
#format file to be in columns, so gnuplot can read it.
WRD=$(head -n 1 layer_t.dat|wc -w); for((i=2;i<=$WRD;i=i+2)); do awk '{print $'$i'}' layer_t.dat| tr '\n' ' ';echo; done > layer.dat

1dplot -sepscl layer.dat
mv layer.dat layer_BOLD.dat

gnuplot "gnuplot_layers.txt"

/Users/barilari/data/tools/LAYNII/LN2_LAYERS -rim moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice.nii -nr_layers 3

/Users/barilari/data/tools/LAYNII/LN_COLUMNAR_DIST -layers moved_scaled_notIso_sub-pilot001_ses-008_task-gratingBimodalMotion_run-006_epiT1w_mask_1slice_layers_equidist_3layers.nii -landmarks notIso_landmarks.nii -vinc 200