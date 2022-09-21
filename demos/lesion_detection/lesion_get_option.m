function [opt, opt2] = lesion_get_option()
  %

  % (C) Copyright 2021 bidspm developers

  % The directory where the data are located

  opt.dir.raw = '/home/remi/gin/Michele/CVI-raw';
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', 'derivatives');
  opt.subjects = {'HH02', 'CTL25'};
  opt.query.run = '02';

  opt.query.modality = 'anat';

  opt.pipeline.type = 'preproc';

  opt.toolbox.ALI.unified_segmentation.step1fwhm = 6;
  opt.toolbox.ALI.unified_segmentation.step1niti = 3;
  % Voxel sizes (in mm)
  opt.toolbox.ALI.unified_segmentation.step1vox = 1;

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

  %%
  opt2.subjects = {'ctrl01'};
  opt2.dir.derivatives = '/home/remi/gin/Christine/olfaction_blind/derivatives/lesion/derivatives/';
  opt2.dir.preproc = fullfile(opt2.dir.derivatives, 'cpp_spm-preproc');
  opt2.query.run = '';
  opt2.query.acq = '';
  opt2.toolbox.ALI.unified_segmentation.step1fwhm = 6;
  opt2 = checkOptions(opt2);
end
