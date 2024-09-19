% (C) Copyright 2022 bidspm developers

bidspm_dir = '/home/remi/github/cpp-lln-lab/bidspm';

overlay_img = fullfile(bidspm_dir, 'demos/MoAE/outputs/derivatives/bidspm-stats/sub-01/task-auditory_space-MNI152NLin6Asym_FWHM-8/mask.nii');

template_img = fullfile(bidspm_dir, 'demos/MoAE/outputs/derivatives/bidspm-preproc/sub-01/func/sub-01_task-auditory_space-MNI152NLin6Asym_desc-smth8_bold.nii');

columns = 9;

rotate = 1;

str = '';

clrmp = 'gray';

visibility = 'on';

saveAs_fn = 0;

template_hdr = spm_vol(template_img);
template = spm_read_vols(template_hdr(1));

mask_hdr = spm_vol(overlay_img);
mask = spm_read_vols(mask_hdr);

fmrwhy_util_createOverlayMontage(template, ...
                                 mask, ...
                                 columns, ...
                                 rotate, ...
                                 '', ...
                                 clrmp, ...
                                 visibility, ...
                                 'max', ...
                                 [0 255], ...
                                 [33, 168, 10], ...
                                 saveAs_fn);
