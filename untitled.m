% (C) Copyright 2022 bidspm developers
close all;

bidspm_dir = '/home/remi/github/cpp-lln-lab/bidspm';

demos_dir = fullfile(bidspm_dir, 'demos/MoAE/outputs/derivatives/');

overlay_img = fullfile(demos_dir, ...
                       'bidspm-stats/sub-01/task-auditory_space-MNI152NLin6Asym_FWHM-8/mask.nii');

template_img = fullfile( ...
                        demos_dir, ...
                        'bidspm-preproc', 'sub-01', 'func', ...
                        'sub-01_task-auditory_space-MNI152NLin6Asym_desc-smth8_bold.nii');

template_hdr = spm_vol(template_img);
template = spm_read_vols(template_hdr(1));

mask_hdr = spm_vol(overlay_img);
mask = spm_read_vols(mask_hdr);

% createMontage(template, 'shape', 'square');
createOverlayMontage(template, mask, 'rgbcolors', [255, 0, 0], ...
                     'shape', 'square');
