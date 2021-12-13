function opt =  face_rep_get_option_results()
  %
  % (C) Copyright 2021 Remi Gau

  opt = [];

  opt.taskName = 'facerepetition';
  opt.verbosity = 1;

  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', 'derivatives');
  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
  opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');

  opt.pipeline.type = 'stats';

  opt.space = {'MNI'};

  opt.model.hrfDerivatives = [1 1];

  opt.model.file = fullfile( ...
                            fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-faceRepetition_smdl.json');

  opt.QA.glm.do = false;

  % Specify the result to compute
  opt.result.Steps(1) = returnDefaultResultsStructure();

  opt.result.Steps(1).Level = 'subject';

  opt.result.Steps(1).Contrasts(1).Name = 'faces_gt_baseline';

  opt.result.Steps(1).Contrasts(1).MC =  'FWE';
  opt.result.Steps(1).Contrasts(1).p = 0.05;
  opt.result.Steps(1).Contrasts(1).k = 5;

  % Specify how you want your output (all the following are on false by default)
  opt.result.Steps(1).Output.png = true();
  opt.result.Steps(1).Output.csv = true();
  opt.result.Steps(1).Output.thresh_spm = true();
  opt.result.Steps(1).Output.binary = true();

  % MONTAGE FIGURE OPTIONS
  opt.result.Steps(1).Output.montage.do = true();
  opt.result.Steps(1).Output.montage.slices = -26:3:6; % in mm
  opt.result.Steps(1).Output.montage.orientation = 'axial';

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
