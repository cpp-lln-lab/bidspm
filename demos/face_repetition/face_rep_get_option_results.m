function opt =  face_rep_get_option_results()
  %
  % (C) Copyright 2021 Remi Gau

  opt = [];

  opt.pipeline.type = 'stats';

  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', 'derivatives');
  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
  opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-faceRepetition_smdl.json');

  % Specify the result to compute
  opt.results = defaultResultsStructure();
  opt.results.nodeName = 'run_level';

  opt.results.name = 'faces_gt_baseline_1';

  % Specify how you want your output (all the following are on false by default)
  opt.results.png = true();
  opt.results.csv = true();
  opt.results.threshSpm = true();
  opt.results.binary = true();
  opt.results.montage.do = true();
  opt.results.montage.slices = -26:3:6; % in mm
  opt.results.montage.orientation = 'axial';

  results = defaultResultsStructure();
  results.nodeName = 'run_level';
  results.name = 'motion';
  results.png = true();

  opt.results(2) = results;

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
