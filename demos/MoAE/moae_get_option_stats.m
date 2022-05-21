function opt = moae_get_option_stats()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2019 Remi Gau

  opt = [];

  opt.stc.skip = 1;

  % The directory where the data are located
  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', '..', 'outputs', 'derivatives');
  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
  opt.dir.input = opt.dir.preproc;
  opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');
  opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', 'model-MoAE_smdl.json');

  % Specify the result to compute
  opt.results(1).nodeName = 'subject';

  opt.results.name = 'listening_1';

  % For each contrats, you can adapt:
  %  - voxel level (p)
  %  - cluster (k) level threshold
  %  - type of multiple comparison:
  %    - 'FWE' is the defaut
  %    - 'FDR'
  %    - 'none'
  %
  %   opt.results(2).Name = 'listening_inf_baseline';
  %   opt.results(2).MC =  'none';
  %   opt.results(2).p = 0.01;
  %   opt.results(2).k = 0;

  % Specify how you want your output (all the following are on false by default)
  opt.results(1).png = true();

  opt.results(1).csv = true();

  opt.results(1).threshSpm = true();

  opt.results(1).binary = true();

  % MONTAGE FIGURE OPTIONS
  opt.results(1).montage.do = true();
  opt.results(1).montage.slices = -4:2:16; % in mm
  % axial is default 'sagittal', 'coronal'
  opt.results(1).montage.orientation = 'axial';
  % will use the MNI T1 template by default but the underlay image can be changed.
  opt.results(1).montage.background = ...
      fullfile(spm('dir'), 'canonical', 'avg152T1.nii');

  opt.results(1).nidm = true();

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
