% (C) Copyright 2019 Remi Gau

function opt = MoAEpilot_getOption()
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.

  opt = [];

  % task to analyze
  opt.taskName = 'auditory';

  % The directory where the data are located
  opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'output', 'MoAEpilot');
  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')));

  % Uncomment the lines below to run preprocessing
  % - don't use realign and unwarp
  % opt.realign.useUnwarp = false;
  % - in "native" space: don't do normalization
  % opt.space = 'individual';

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', 'model-MoAE_smdl.json');
  % to add the hrf temporal derivative = [1 0]
  % to add the hrf temporal and dispersion derivative = [1 1]
  % opt.model.hrfDerivatives = [0 0];

  % Specify the result to compute
  opt.result.Steps(1) = returnDefaultResultsStructure();

  opt.result.Steps(1).Level = 'subject';

  opt.result.Steps(1).Contrasts(1).Name = 'listening';

  opt.result.Steps(1).Contrasts(2).Name = 'listening_inf_baseline';

  % For each contrats, you can adapt:
  %  - voxel level (p)
  %  - cluster (k) level threshold
  %  - type of multiple comparison:
  %    - 'FWE' is the defaut
  %    - 'FDR'
  %    - 'none'
  opt.result.Steps(1).Contrasts(2).MC =  'none';
  opt.result.Steps(1).Contrasts(2).p = 0.01;
  opt.result.Steps(1).Contrasts(2).k = 0;

  % Specify how you want your output (all the following are on false by default)
  opt.result.Steps(1).Output.png = true();
  opt.result.Steps(1).Output.csv = true();
  opt.result.Steps(1).Output.thresh_spm = true();
  opt.result.Steps(1).Output.binary = true();
  opt.result.Steps(1).Output.montage = true();
  opt.result.Steps(1).Output.NIDM_results = true();

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
