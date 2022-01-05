function opt = moae_get_option_stats()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2019 Remi Gau

  opt = [];

  % task to analyze
  opt.verbosity = 1;

  % The directory where the data are located
  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', '..', 'outputs', 'derivatives');
  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
  opt.dir.input = opt.dir.preproc;
  opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');
  opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', 'model-MoAE_smdl.json');
  % to add the hrf temporal derivative = [1 0]
  % to add the hrf temporal and dispersion derivative = [1 1]
  % opt.model.hrfDerivatives = [0 0];

  % Specify the result to compute
  opt.result.Nodes(1) = returnDefaultResultsStructure();

  opt.result.Nodes(1).Level = 'subject';

  opt.result.Nodes(1).Contrasts(1).Name = 'listening_1';

  % For each contrats, you can adapt:
  %  - voxel level (p)
  %  - cluster (k) level threshold
  %  - type of multiple comparison:
  %    - 'FWE' is the defaut
  %    - 'FDR'
  %    - 'none'
  %
  %   opt.result.Nodes(1).Contrasts(2).Name = 'listening_inf_baseline';
  %   opt.result.Nodes(1).Contrasts(2).MC =  'none';
  %   opt.result.Nodes(1).Contrasts(2).p = 0.01;
  %   opt.result.Nodes(1).Contrasts(2).k = 0;

  % Specify how you want your output (all the following are on false by default)
  opt.result.Nodes(1).Output.png = true();

  opt.result.Nodes(1).Output.csv = true();

  opt.result.Nodes(1).Output.thresh_spm = true();

  opt.result.Nodes(1).Output.binary = true();

  % MONTAGE FIGURE OPTIONS
  opt.result.Nodes(1).Output.montage.do = true();
  opt.result.Nodes(1).Output.montage.slices = -0:2:16; % in mm
  % axial is default 'sagittal', 'coronal'
  opt.result.Nodes(1).Output.montage.orientation = 'axial';
  % will use the MNI T1 template by default but the underlay image can be changed.
  opt.result.Nodes(1).Output.montage.background = ...
      fullfile(spm('dir'), 'canonical', 'avg152T1.nii');

  opt.result.Nodes(1).Output.NIDM_results = true();

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
